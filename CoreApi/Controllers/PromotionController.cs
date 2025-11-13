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
    [Route("api/promotions")]
    public class PromotionsController : ControllerBase
    {
        private IPromotionsBusiness _promotionsBusiness;
        private IAuditLogger _auditLogger;

        public PromotionsController(IPromotionsBusiness promotionsBusiness, IAuditLogger auditLogger)
        {
            _promotionsBusiness = promotionsBusiness;
            _auditLogger = auditLogger;
        }

        [Route("create")]
        [HttpPost]
        public PromotionsModel Create([FromBody] PromotionsModel model)
        {
            _promotionsBusiness.Create(model);
            _auditLogger.Log(
                action:$"Create promotion: {model.PromotionName}",
                entityName: "Promotions",
                entityId: model.PromotionID,
                operation: "CREATE",
                details: JsonSerializer.Serialize(model)
                );
            return (model);
        }

        [Route("update")]
        [HttpPost]
        public PromotionsModel Update([FromBody] PromotionsModel model)
        {
            _promotionsBusiness.Update(model);
            _auditLogger.Log(
                action:$"Update promotion {model.PromotionName}",
                entityName: "Promotions",
                entityId: model.PromotionID,
                operation:"UPDATE",
                details: JsonSerializer.Serialize(model)
                );
            return model;
        }

        [Route("delete")]
        [HttpPost]
        public IActionResult Delete([FromBody] PromotionsModel model)
        {
            _promotionsBusiness.Delete(model);
            _auditLogger.Log(
                action: $"Delete promotion {model.PromotionName}",
                entityName:"Promotions",
                entityId: model.PromotionID,
                operation:"DELETE",
                details: null
                );
            return Ok(new { data = "ok" });
        }

        [Route("get-by-id/{id}")]
        [HttpGet]
        public PromotionsModel GetDatabyID(int id)
        {
            return _promotionsBusiness.GetDatabyID(id);
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
                decimal? minValue = null, maxValue = null;
                string type = null;
                int? categoryId = null;
                DateTime? fromDate = null, toDate = null;

                if (formData != null)
                {
                    if (formData.ContainsKey("minValue"))
                    {
                        var val = Convert.ToString(formData["minValue"])?.Trim();
                        if (decimal.TryParse(val, NumberStyles.Any, CultureInfo.InvariantCulture, out var d))
                            minValue = d;
                    }

                    if (formData.ContainsKey("maxValue"))
                    {
                        var val = Convert.ToString(formData["maxValue"])?.Trim();
                        if (decimal.TryParse(val, NumberStyles.Any, CultureInfo.InvariantCulture, out var d))
                            maxValue = d;
                    }

                    if (formData.ContainsKey("type"))
                        type = Convert.ToString(formData["type"])?.Trim();

                    if (formData.ContainsKey("categoryId"))
                    {
                        var val = Convert.ToString(formData["categoryId"])?.Trim();
                        if (int.TryParse(val, out var cid))
                            categoryId = cid;
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
                }

                // --- CALL BLL ---
                long total = 0;
                var data = _promotionsBusiness.Search(
                    page, pageSize, out total,
                    minValue, maxValue, type, categoryId, fromDate, toDate);

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
