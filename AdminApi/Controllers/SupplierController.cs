using BLL;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Model;
using ClosedXML.Excel;
using System.Globalization;

namespace AdminApi.Controllers
{
    [Route("api/supplier")]
    [ApiController]
    public class SupplierController : ControllerBase
    {
        private ISupplierBusiness _supplierbusiness;
        public SupplierController(ISupplierBusiness supplierbusiness)
        {
            _supplierbusiness = supplierbusiness;
        }

        [Authorize(Roles =("Admin,ThuKho"))]
        
        [Route("create-supplier")]
        [HttpPost]
        public SupplierModel Create(SupplierModel model)
        {
            _supplierbusiness.Create(model);
            return model;
        }

        [Authorize(Roles=("Admin,ThuKho"))]
        
        [Route("update-supplier")]
        [HttpPost]
        public SupplierModel Update(SupplierModel model)
        {
            _supplierbusiness.Update(model);
            return model;
        }

        [Authorize(Roles =("Admin"))]
        
        [Route("delete-supplier/{id}")]
        [HttpPost]
        public IActionResult DeleteSupplier( int id)
        {
            var ok = _supplierbusiness.Delete(id);
            if(ok)
            {
                return Ok(new { message = "Đã xoá thành công!" });
            }
            else
            {
                return Ok(new { message = "Xoá không thành công" });
            }
        }

        [Authorize(Roles =("Admin,ThuKho,KeToan"))]
        
        [Route("get-by-id/{id}")]
        [HttpGet]
        public SupplierModel GetdataByID(int id)
        {
            return _supplierbusiness.GetdataByID(id);
        }

        [Authorize(Roles ="Admin,ThuKho,KeToan")]
        
        [Route("search")]
        [HttpPost]
        public ResponseModel Search([FromBody] Dictionary<string,object> formdata)
        {
            var response = new ResponseModel();
            try
            {
                var pageIndex= int.Parse(formdata["pageIndex"].ToString());
                var pageSize = int.Parse(formdata["pageSize"].ToString());
                string Phone = "";
                if ((formdata.Keys.Contains("Phone") || formdata.Keys.Contains("phone")) &&
                    !string.IsNullOrEmpty(Convert.ToString(formdata.ContainsKey("Phone") ? formdata["Phone"] : formdata["phone"])))
                {
                    Phone = Convert.ToString(formdata.ContainsKey("Phone") ? formdata["Phone"] : formdata["phone"]);
                }
                var data = _supplierbusiness.Search(pageIndex, pageSize,out long total, Phone);
                response.TotalItems = total;
                response.Data = data;
                response.Page = pageIndex;
                response.PageSize = pageSize;

            }
            catch(Exception ex)
            {
                throw ex;
            }
            return response;
        }

        // ================== EXPORT EXCEL SUPPLIER ==================
        [Authorize(Roles = ("Admin,ThuKho,KeToan"))]
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

                var data = _supplierbusiness.Search(
                    1,
                    MAX_ROWS,
                    out total,
                    phone
                );

                // Tạo file Excel
                using var workbook = new XLWorkbook();
                var ws = workbook.Worksheets.Add("Suppliers");

                // Header
                ws.Cell(1, 1).Value = "SupplierID";
                ws.Cell(1, 2).Value = "SupplierName";
                ws.Cell(1, 3).Value = "Phone";
                ws.Cell(1, 4).Value = "Email";
                ws.Cell(1, 5).Value = "Address";

                int row = 2;
                foreach (var s in data)
                {
                    ws.Cell(row, 1).Value = s.SupplierID;
                    ws.Cell(row, 2).Value = s.SupplierName ?? "";
                    ws.Cell(row, 3).Value = s.Phone ?? "";
                    ws.Cell(row, 4).Value = s.Email ?? "";
                    ws.Cell(row, 5).Value = s.Address ?? "";
                    row++;
                }

                ws.Columns().AdjustToContents();

                using var stream = new MemoryStream();
                workbook.SaveAs(stream);
                stream.Position = 0;

                var fileName = $"suppliers_{DateTime.UtcNow:yyyyMMdd_HHmmss}.xlsx";
                const string contentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";

                return File(stream.ToArray(), contentType, fileName);
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        // ================= IMPORT EXCEL SUPPLIER =================
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

                    // ===== SupplierID: cho phép trống / không phải số =====
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

                    // Bắt buộc phải có tên
                    if (string.IsNullOrWhiteSpace(name))
                        continue;

                    var model = new SupplierModel
                    {
                        SupplierID = id,
                        SupplierName = name,
                        Phone = phone,
                        Email = email,
                        Address = address
                    };

                    if (id > 0)
                    {
                        _supplierbusiness.Update(model);
                        updated++;
                    }
                    else
                    {
                        _supplierbusiness.Create(model);
                        created++;
                    }
                }

                return Ok(new
                {
                    message = "Import Excel nhà cung cấp thành công.",
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
