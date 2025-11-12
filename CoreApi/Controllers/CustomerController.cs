using BLL;
using Model;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using ClosedXML.Excel;
using System.Globalization;

namespace CoreApi.Controllers
{
    [Route("api/customer")]
    [ApiController]
    public class CustomerController : ControllerBase
    {
        private ICustomerBusiness _customerBusiness;
        public CustomerController(ICustomerBusiness customerBusiness)
        {
            _customerBusiness = customerBusiness;
        }

        [Authorize(Roles =("Admin,ThuNgan,KeToan"))]
        [Route("get-by-id/{id}")]
        [HttpGet]
        public CustomerModel GetdatabyId(int id)
        {
            return _customerBusiness.GetdataById(id);
        }

        [Authorize(Roles =("Admin,ThuNgan"))]
        [Route("create-customer")]
        [HttpPost]
        public CustomerModel Create(CustomerModel model)
        {
            _customerBusiness.Create(model);
            return model;
        }

        [Authorize(Roles =("Admin,ThuNgan"))]
        [Route("update-customer")]
        [HttpPost]
        public CustomerModel Update(CustomerModel model)
        {
            _customerBusiness.Update(model);
            return model;
        }

        [Authorize(Roles =("Admin"))]
        [Route("delete-customer/{id}")]
        [HttpPost]
        public IActionResult DeleteCustomer(int id)
        {
            var ok = _customerBusiness.Delete(id);
            if(ok)
            {
                return Ok(new { message = "Đã xoá thành công" });
            }
            else
            {
                return Ok(new { message = "Xoá không thành công" });
            }

        }

        [Authorize(Roles =("Admin,ThuNgan,KeToan"))]
        [Route("search-customer")]
        [HttpPost]
        public ResponseModel Search([FromBody] Dictionary<string,object> formdata)
        {
            var respose = new ResponseModel();
            try
            {
                var pageIndex = int.Parse(formdata["pageIndex"].ToString());
                var pageSize = int.Parse(formdata["pageSize"].ToString()) ;
                string Phone = "";
                if (formdata.Keys.Contains("Phone") && !string.IsNullOrEmpty(Convert.ToString(formdata["Phone"])))
                {
                    Phone = Convert.ToString(formdata["Phone"]);
                }
                string Address = "";
                if(formdata.Keys.Contains("Address")&& !string.IsNullOrEmpty(Convert.ToString(formdata["Address"])))
                {
                    Address = Convert.ToString(formdata["Address"]);
                }

                var data = _customerBusiness.Search(pageIndex, pageSize,out long toal, Phone, Address);
                respose.TotalItems = toal;
                respose.Data = data;
                respose.Page = pageIndex;
                respose.PageSize = pageSize;

            }
            catch(Exception ex)
            {
                throw ex;
            }
            return respose;
        }

        // ================== EXPORT EXCEL CUSTOMER ==================
        [Authorize(Roles = ("Admin,ThuNgan,KeToan"))]
        [Route("export-excel")]
        [HttpPost]
        public IActionResult ExportExcel([FromBody] Dictionary<string, object>? formData)
        {
            try
            {
                // Lấy filter giống Search (trừ paging)
                string phone = string.Empty;
                string address = string.Empty;

                if (formData != null)
                {
                    if (formData.ContainsKey("Phone"))
                    {
                        phone = (Convert.ToString(formData["Phone"]) ?? string.Empty).Trim();
                    }
                    if (formData.ContainsKey("Address"))
                    {
                        address = (Convert.ToString(formData["Address"]) ?? string.Empty).Trim();
                    }
                }

                // Lấy toàn bộ data theo filter (không phân trang)
                long total = 0;
                const int MAX_ROWS = int.MaxValue;

                var data = _customerBusiness.Search(
                    1,
                    MAX_ROWS,
                    out total,
                    phone,
                    address
                );

                // Tạo file Excel
                using var workbook = new XLWorkbook();
                var ws = workbook.Worksheets.Add("Customers");

                // Header
                ws.Cell(1, 1).Value = "CustomerID";
                ws.Cell(1, 2).Value = "CustomerName";
                ws.Cell(1, 3).Value = "Phone";
                ws.Cell(1, 4).Value = "Email";
                ws.Cell(1, 5).Value = "Address";
                ws.Cell(1, 6).Value = "DebtLimit";

                int row = 2;
                foreach (var c in data)
                {
                    ws.Cell(row, 1).Value = c.CustomerID;
                    ws.Cell(row, 2).Value = c.CustomerName ?? "";
                    ws.Cell(row, 3).Value = c.Phone ?? "";
                    ws.Cell(row, 4).Value = c.Email ?? "";
                    ws.Cell(row, 5).Value = c.Address ?? "";
                    ws.Cell(row, 6).Value = c.DebtLimit; // decimal
                    row++;
                }

                ws.Columns().AdjustToContents();

                using var stream = new MemoryStream();
                workbook.SaveAs(stream);
                stream.Position = 0;

                var fileName = $"customers_{DateTime.UtcNow:yyyyMMdd_HHmmss}.xlsx";
                const string contentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";

                return File(stream.ToArray(), contentType, fileName);
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        //IMPORT EXCEL

        [Route("import-excel")]
        [HttpPost]
        [Consumes("multipart/form-data")]
        public async Task<IActionResult> ImportExcel(IFormFile? file)
        {
            if (file == null || file.Length == 0)
                return BadRequest("File rỗng hoặc không tồn tại.");

            int created = 0;
            int updated = 0;
            int rowNo = 0;

            try
            {
                using var stream = new MemoryStream();
                await file.CopyToAsync(stream);
                stream.Position = 0;

                using var workbook = new XLWorkbook(stream);
                var ws = workbook.Worksheets.Worksheet(1); // sheet đầu tiên

                var range = ws.RangeUsed();
                if (range == null)
                    return BadRequest("File không có dữ liệu.");

                // Bỏ dòng header
                foreach (var row in range.RowsUsed().Skip(1))
                {
                    rowNo = row.RowNumber();

                    // ===== CustomerID: cho phép trống / không phải số =====
                    int id = 0;
                    var idCell = row.Cell(1);
                    var idStr = idCell.GetString().Trim();

                    if (!string.IsNullOrEmpty(idStr))
                    {
                        int.TryParse(idStr, out id); // nếu parse fail => id = 0
                    }

                    string name = row.Cell(2).GetString().Trim();
                    string phone = row.Cell(3).GetString().Trim();
                    string email = row.Cell(4).GetString().Trim();
                    string address = row.Cell(5).GetString().Trim();

                    decimal debtLimit = 0;
                    var debtStr = row.Cell(6).GetString().Trim();
                    if (!string.IsNullOrEmpty(debtStr))
                    {
                        decimal.TryParse(
                            debtStr.Replace(',', '.'),
                            NumberStyles.Number,
                            CultureInfo.InvariantCulture,
                            out debtLimit
                        );
                    }

                    // Bắt buộc phải có tên
                    if (string.IsNullOrWhiteSpace(name))
                        continue;

                    var model = new CustomerModel
                    {
                        CustomerID = id,
                        CustomerName = name,
                        Phone = phone,
                        Email = email,
                        Address = address,
                        DebtLimit = debtLimit
                    };

                    if (id > 0)
                    {
                        _customerBusiness.Update(model);
                        updated++;
                    }
                    else
                    {
                        _customerBusiness.Create(model);
                        created++;
                    }
                }

                return Ok(new
                {
                    message = "Import Excel khách hàng thành công.",
                    created,
                    updated
                });
            }
            catch (Exception ex)
            {
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    $"Lỗi khi import Excel tại dòng {rowNo}: {ex.Message}"
                );
            }
        }

    }
}
