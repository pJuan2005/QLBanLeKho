using BLL;
using Model;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using BLL.Interfaces;
using System.Globalization;
using System.Text;
using System.IO;
using ClosedXML.Excel;

namespace CoreApi.Controllers
{
    [Route("api/category")]
    [ApiController]
    public class CategoryController : ControllerBase
    {
        private ICategoryBusiness _categoryBusiness;
        public CategoryController(ICategoryBusiness categoryBusiness)
        {
            _categoryBusiness = categoryBusiness;
        }

        [Route("update-category")]
        [HttpPost]
        public CategoryModel Update([FromBody]CategoryModel model)
        {
            _categoryBusiness.Update(model);
            return model;
        }

        [Route("get-by-id/{id}")]
        [HttpGet]
        public CategoryModel GetDatabyId(int id)
        {
            return _categoryBusiness.GetDatabyID(id);

        }

        [Route("create-category")]
        [HttpPost]
        public CategoryModel Create([FromBody]CategoryModel model)
        {
             _categoryBusiness.Create(model);
             return model;
        }

        [Route("delete-category")]
        [HttpPost]
        public IActionResult Delete([FromBody]int Id)
        {
            var ok = _categoryBusiness.Delete(Id);
            if (ok)
            {
                return Ok(new { message = "Đã Xoá thành công",Id });
            }
            else
            {
                return Ok(new { message = "Xoá không thành công", Id });
            }
        }
        [Route("search")]
        [HttpPost]
        public ResponseModel Search([FromBody] Dictionary<string, object> formData)
        {
            var response = new ResponseModel();
            try
            {
                // --- paging ---
                int page = 1, pageSize = 10;
                if (formData != null)
                {
                    if (formData.ContainsKey("page") &&
                        int.TryParse(Convert.ToString(formData["page"]), out var p) && p > 0) page = p;

                    if (formData.ContainsKey("pageSize") &&
                        int.TryParse(Convert.ToString(formData["pageSize"]), out var ps) && ps > 0) pageSize = ps;
                }

                // --- filters ---
                int? categoryId = null;
                if (formData != null && formData.ContainsKey("CategoryID") &&
                    int.TryParse(Convert.ToString(formData["CategoryID"]), out var tmpId))
                    categoryId = tmpId;

                string categoryName = formData != null && formData.ContainsKey("CategoryName")
                    ? (Convert.ToString(formData["CategoryName"]) ?? string.Empty).Trim()
                    : string.Empty;

                string option = formData != null && formData.ContainsKey("option")
                    ? (Convert.ToString(formData["option"]) ?? string.Empty).Trim()
                    : string.Empty;

                // --- VAT filters (exact OR range) ---
                decimal? vatExact = null, vatFrom = null, vatTo = null;

                decimal ParseDecimal(object val)
                {
                    if (val == null) return 0m;
                    var s = Convert.ToString(val)?.Trim();
                    if (string.IsNullOrEmpty(s)) return 0m;
                    // chấp nhận "9,5" hoặc "9.5"
                    s = s.Replace(',', '.');
                    return decimal.TryParse(s, NumberStyles.Number, CultureInfo.InvariantCulture, out var d) ? d : 0m;
                }

                if (formData != null && formData.ContainsKey("vatExact"))
                {
                    var d = ParseDecimal(formData["vatExact"]);
                    if (d > 0 || (Convert.ToString(formData["vatExact"]) ?? "") == "0")
                        vatExact = d;
                }

                if (vatExact == null) // chỉ dùng khoảng khi không có exact
                {
                    if (formData != null && formData.ContainsKey("vat_from"))
                    {
                        var d = ParseDecimal(formData["vat_from"]);
                        if (d > 0 || (Convert.ToString(formData["vat_from"]) ?? "") == "0")
                            vatFrom = d;
                    }
                    if (formData != null && formData.ContainsKey("vat_to"))
                    {
                        var d = ParseDecimal(formData["vat_to"]);
                        if (d > 0 || (Convert.ToString(formData["vat_to"]) ?? "") == "0")
                            vatTo = d;
                    }
                }

                // --- call BLL ---
                long total = 0;
                // Cập nhật chữ ký BLL: Search(page, pageSize, out total, categoryId, categoryName, option, vatExact, vatFrom, vatTo)
                var data = _categoryBusiness.Search(
                    page, pageSize, out total,
                    categoryId, categoryName, option,
                    vatExact, vatFrom, vatTo
                );

                response.TotalItems = total;
                response.Data = data;
                response.Page = page;
                response.PageSize = pageSize;
                return response;
            }
            catch (Exception ex)
            {
                // log nếu cần
                throw new Exception(ex.Message);
            }
        }

        //export excel
        [Route("export-excel")]
        [HttpPost]
        public IActionResult ExportExcel([FromBody] Dictionary<string, object>? formData)
        {
            try
            {
                // ==== Đọc filter giống Search (trừ paging) ====
                int? categoryId = null;
                if (formData != null && formData.ContainsKey("CategoryID") &&
                    int.TryParse(Convert.ToString(formData["CategoryID"]), out var tmpId))
                {
                    categoryId = tmpId;
                }

                string categoryName = formData != null && formData.ContainsKey("CategoryName")
                    ? (Convert.ToString(formData["CategoryName"]) ?? string.Empty).Trim()
                    : string.Empty;

                string option = formData != null && formData.ContainsKey("option")
                    ? (Convert.ToString(formData["option"]) ?? string.Empty).Trim()
                    : string.Empty;

                decimal? vatExact = null, vatFrom = null, vatTo = null;

                decimal ParseDecimal(object val)
                {
                    if (val == null) return 0m;
                    var s = Convert.ToString(val)?.Trim();
                    if (string.IsNullOrEmpty(s)) return 0m;
                    s = s.Replace(',', '.');
                    return decimal.TryParse(s, NumberStyles.Number, CultureInfo.InvariantCulture, out var d) ? d : 0m;
                }

                if (formData != null && formData.ContainsKey("vatExact"))
                {
                    var d = ParseDecimal(formData["vatExact"]);
                    if (d > 0 || (Convert.ToString(formData["vatExact"]) ?? "") == "0")
                        vatExact = d;
                }

                if (vatExact == null)
                {
                    if (formData != null && formData.ContainsKey("vat_from"))
                    {
                        var d = ParseDecimal(formData["vat_from"]);
                        if (d > 0 || (Convert.ToString(formData["vat_from"]) ?? "") == "0")
                            vatFrom = d;
                    }
                    if (formData != null && formData.ContainsKey("vat_to"))
                    {
                        var d = ParseDecimal(formData["vat_to"]);
                        if (d > 0 || (Convert.ToString(formData["vat_to"]) ?? "") == "0")
                            vatTo = d;
                    }
                }

                // ==== Lấy toàn bộ dữ liệu theo filter (không phân trang) ====
                long total = 0;
                const int MAX_ROWS = int.MaxValue;
                var data = _categoryBusiness.Search(
                    1,
                    MAX_ROWS,
                    out total,
                    categoryId,
                    categoryName,
                    option,
                    vatExact,
                    vatFrom,
                    vatTo
                );

                // ==== Tạo file Excel bằng ClosedXML ====
                using var workbook = new XLWorkbook();
                var ws = workbook.Worksheets.Add("Categories");

                // Header
                ws.Cell(1, 1).Value = "CategoryID";
                ws.Cell(1, 2).Value = "CategoryName";
                ws.Cell(1, 3).Value = "Description";
                ws.Cell(1, 4).Value = "VATRate";

                int row = 2;
                foreach (var c in data)
                {
                    ws.Cell(row, 1).Value = c.CategoryID;
                    ws.Cell(row, 2).Value = c.CategoryName ?? "";
                    ws.Cell(row, 3).Value = c.Description ?? "";
                    ws.Cell(row, 4).Value = c.VATRate; // decimal? tự map được
                    row++;
                }

                // format nhẹ cho đẹp (tuỳ bạn)
                ws.Columns().AdjustToContents();

                using var stream = new MemoryStream();
                workbook.SaveAs(stream);
                stream.Position = 0;

                var fileName = $"categories_{DateTime.UtcNow:yyyyMMdd_HHmmss}.xlsx";
                const string contentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";

                return File(stream.ToArray(), contentType, fileName);
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

        //import excel
        // import excel
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

                // Bỏ dòng header (row 1)
                foreach (var row in range.RowsUsed().Skip(1))
                {
                    rowNo = row.RowNumber();

                    int id = row.Cell(1).GetValue<int>();
                    string name = row.Cell(2).GetString().Trim();
                    string desc = row.Cell(3).GetString().Trim();

                    decimal? vat = null;
                    if (decimal.TryParse(
                            row.Cell(4).GetString().Replace(',', '.'),
                            NumberStyles.Number,
                            CultureInfo.InvariantCulture,
                            out var dv))
                    {
                        vat = dv;
                    }

                    if (string.IsNullOrWhiteSpace(name))
                        continue;

                    var model = new CategoryModel
                    {
                        CategoryID = id,
                        CategoryName = name,
                        Description = desc,
                        VATRate = vat
                    };

                    if (id > 0)
                    {
                        _categoryBusiness.Update(model);
                        updated++;
                    }
                    else
                    {
                        _categoryBusiness.Create(model);
                        created++;
                    }
                }

                return Ok(new
                {
                    message = "Import Excel thành công.",
                    created,
                    updated
                });
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError,
                    $"Lỗi khi import Excel tại dòng {rowNo}: {ex.Message}");
            }
        }

    }
}
