using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using BLL;
using System.Reflection;
using BLL.Interfaces;
using Model;
using AdminApi.Services.Interface;
using System.Text.Json;
using System.Globalization;
using Microsoft.AspNetCore.Authorization;

namespace CoreApi.Controllers
{
    [Route("api/sales")]
    [ApiController]
    [Authorize]
    public class SalesController : ControllerBase
    {
        private ISalesBusiness _salesBusiness;
        private IAuditLogger _auditLogger;

        public SalesController(ISalesBusiness salesBusiness, IAuditLogger auditLogger)
        {
            _salesBusiness = salesBusiness;
            _auditLogger = auditLogger;
        }

        [Route("create")]
        [HttpPost]
        public SalesModel Create([FromBody] SalesModel model)
        {
            _salesBusiness.Create(model);
            _auditLogger.Log(
                action: $"Create sales Id: {model.SaleID}",
                entityName: "Sales",
                entityId: model.SaleID,
                operation: "CREATE",
                details: JsonSerializer.Serialize(model)
                );
            return model;
        }

        [Route("update")]
        [HttpPost]
        public SalesModel Update([FromBody] SalesModel model)
        {
            _salesBusiness.Update(model);
            _auditLogger.Log(
                action: $"Update sales Id: {model.SaleID}",
                entityName:"Sales",
                entityId: model.SaleID,
                operation: "UPDATE",
                details: JsonSerializer.Serialize(model)
                );
            return model;
        }

        [Route("delete")]
        [HttpPost]
        public IActionResult Delete([FromBody] SalesModel model)
        {
            _salesBusiness.Delete(model);
            _auditLogger.Log(
                action: $"Delete sales Id: {model.SaleID}",
                entityName:"Sales",
                entityId: model.SaleID,
                operation: "DELETE",
                details: null
                );
            return Ok(new { data = "ok" });
        }

        [Route("get-by-id/{id}")]
        [HttpGet]
        public SalesModel GetDatabyID(int id)
        {
            return _salesBusiness.GetDatabyID(id);
        }

        [Route("search")]
        [HttpPost]
        public ResponseModel Search([FromBody] Dictionary<string, object> formData)
        {
            var response = new ResponseModel();
            try
            {
                // --- PAGING ---
                int page = 1, pageSize = 10;
                if (formData != null)
                {
                    if (formData.ContainsKey("page") && int.TryParse(Convert.ToString(formData["page"]), out var p) && p > 0)
                        page = p;
                    if (formData.ContainsKey("pageSize") && int.TryParse(Convert.ToString(formData["pageSize"]), out var ps) && ps > 0)
                        pageSize = ps;
                }

                // --- FILTERS ---
                decimal? minTotalAmount = null, maxTotalAmount = null;
                string status = null;
                DateTime? fromDate = null, toDate = null;

                if (formData != null)
                {
                    if (formData.ContainsKey("minTotalAmount"))
                    {
                        var val = Convert.ToString(formData["minTotalAmount"])?.Trim();
                        if (decimal.TryParse(val, NumberStyles.Any, CultureInfo.InvariantCulture, out var d))
                            minTotalAmount = d;
                    }
                    if (formData.ContainsKey("maxTotalAmount"))
                    {
                        var val = Convert.ToString(formData["maxTotalAmount"])?.Trim();
                        if (decimal.TryParse(val, NumberStyles.Any, CultureInfo.InvariantCulture, out var d))
                            maxTotalAmount = d;
                    }
                    if (formData.ContainsKey("status"))
                        status = Convert.ToString(formData["status"])?.Trim();
                    if (formData.ContainsKey("fromDate"))
                    {
                        var val = Convert.ToString(formData["fromDate"]);
                        if (DateTime.TryParse(val, out var d))
                            fromDate = d;
                    }
                    if (formData.ContainsKey("toDate"))
                    {
                        var val = Convert.ToString(formData["toDate"]);
                        if (DateTime.TryParse(val, out var d))
                            toDate = d;
                    }
                }

                // --- CALL BLL ---
                long total = 0;
                var data = _salesBusiness.Search(
                    page, pageSize, out total,
                    minTotalAmount, maxTotalAmount, status, fromDate, toDate);

                response.TotalItems = total;
                response.Data = data;
                response.Page = page;
                response.PageSize = pageSize;
                return response;
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
        }

        [HttpPost]
        [Route("create-from-pos")]
        public IActionResult CreateFromPos([FromBody] PosOrderDto dto)
        {
            try
            {
                // 1. Lấy UserId từ token (claim tên "UserId")
                var userIdStr = User.FindFirst("UserId")?.Value;
                if (!int.TryParse(userIdStr, out var userId))
                {
                    throw new Exception("Không tìm thấy UserId trong token.");
                }

                // 2. Gán vào dto để BLL/DAL dùng
                dto.UserId = userId;

                // 3. Gọi BLL
                var result = _salesBusiness.CreateFromPos(dto);

                _auditLogger.Log(
                    action: $"Đã tạo một đơn bán hàng có id: {result.Sale.SaleID}",
                    entityName: "Sales",
                    entityId: result.Sale.SaleID,
                    operation: "CREATE",
                    details: JsonSerializer.Serialize(dto)
                );

                return Ok(result); // FE cần toàn bộ sale với debt mới
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [Route("dashboard")]
        [HttpPost]
        public IActionResult GetDashboard([FromBody] Dictionary<string, object> formData)
        {
            try
            {
                decimal? minTotalAmount = null, maxTotalAmount = null;
                string status = null;
                DateTime? fromDate = null, toDate = null;
                string keyword = null; // invoice hoặc customer name

                if (formData != null)
                {
                    if (formData.ContainsKey("minTotalAmount"))
                    {
                        var val = Convert.ToString(formData["minTotalAmount"])?.Trim();
                        if (decimal.TryParse(val, NumberStyles.Any, CultureInfo.InvariantCulture, out var d))
                            minTotalAmount = d;
                    }

                    if (formData.ContainsKey("maxTotalAmount"))
                    {
                        var val = Convert.ToString(formData["maxTotalAmount"])?.Trim();
                        if (decimal.TryParse(val, NumberStyles.Any, CultureInfo.InvariantCulture, out var d))
                            maxTotalAmount = d;
                    }

                    if (formData.ContainsKey("status"))
                    {
                        var sVal = Convert.ToString(formData["status"]);
                        if (!string.IsNullOrWhiteSpace(sVal))
                            status = sVal.Trim();
                        else
                            status = null;
                    }

                    if (formData.ContainsKey("fromDate"))
                    {
                        var val = Convert.ToString(formData["fromDate"]);
                        if (DateTime.TryParse(val, out var d))
                            fromDate = d;
                    }

                    if (formData.ContainsKey("toDate"))
                    {
                        var val = Convert.ToString(formData["toDate"]);
                        if (DateTime.TryParse(val, out var d))
                            toDate = d;
                    }

                    if (formData.ContainsKey("keyword"))
                    {
                        var kVal = Convert.ToString(formData["keyword"]);
                        if (!string.IsNullOrWhiteSpace(kVal))
                            keyword = kVal.Trim();
                        else
                            keyword = null;
                    }
                }

                var dto = _salesBusiness.GetDashboard(
                    minTotalAmount, maxTotalAmount,
                    status, fromDate, toDate,
                    keyword
                );

                return Ok(dto);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [Route("list")]
        [HttpPost]
        public ResponseModel GetSalesList([FromBody] Dictionary<string, object> formData)
        {
            var response = new ResponseModel();
            try
            {
                int page = 1, pageSize = 10;
                string status = null;
                DateTime? fromDate = null, toDate = null;
                string keyword = null;

                if (formData != null)
                {
                    if (formData.ContainsKey("page"))
                        int.TryParse(Convert.ToString(formData["page"]), out page);
                    if (formData.ContainsKey("pageSize"))
                        int.TryParse(Convert.ToString(formData["pageSize"]), out pageSize);

                    // --- STATUS ---
                    if (formData.ContainsKey("status"))
                    {
                        var sVal = Convert.ToString(formData["status"]);
                        status = string.IsNullOrWhiteSpace(sVal) ? null : sVal.Trim();
                    }

                    // --- FROM DATE ---
                    if (formData.ContainsKey("fromDate") &&
                        DateTime.TryParse(Convert.ToString(formData["fromDate"]), out var fd))
                        fromDate = fd;

                    // --- TO DATE ---
                    if (formData.ContainsKey("toDate") &&
                        DateTime.TryParse(Convert.ToString(formData["toDate"]), out var td))
                        toDate = td;

                    // --- KEYWORD ---
                    if (formData.ContainsKey("keyword"))
                    {
                        var kVal = Convert.ToString(formData["keyword"]);
                        keyword = string.IsNullOrWhiteSpace(kVal) ? null : kVal.Trim();
                    }
                }

                long total = 0;
                var data = _salesBusiness.SearchList(
                    page, pageSize, out total,
                    status, fromDate, toDate, keyword);

                response.Page = page;
                response.PageSize = pageSize;
                response.TotalItems = total;
                response.Data = data;

                return response;
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
        }

        [HttpGet]
        [Route("detail")]
        public IActionResult GetDetail([FromQuery(Name = "saleId")] int saleId)
        {
            if (saleId <= 0)
                return BadRequest(new { message = "saleId không hợp lệ" });

            var detail = _salesBusiness.GetDetail(saleId);
            if (detail == null || detail.Sale == null)
                return NotFound(new { message = "Không tìm thấy đơn sale." });

            // Trả đúng structure mà FE đang expect: sale, items, totals
            return Ok(new
            {
                sale = detail.Sale,
                items = detail.Items,
                totals = detail.Totals
            });
        }
    }
}