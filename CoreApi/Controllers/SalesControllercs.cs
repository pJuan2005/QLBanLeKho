using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using BLL;
using System.Reflection;
using BLL.Interfaces;
using Model;
using AdminApi.Services.Interface;
using System.Text.Json;
using System.Globalization;

namespace CoreApi.Controllers
{
    [Route("api/sales")]
    [ApiController]
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
    }
}