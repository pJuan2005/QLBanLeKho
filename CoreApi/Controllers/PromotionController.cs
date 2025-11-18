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
                var pageIndex = int.Parse(formData["pageIndex"].ToString());
                var pageSize = int.Parse(formData["pageSize"].ToString());

                DateTime? fromDate = null, toDate = null;
                string status = "";

                if (formData.Keys.Contains("fromDate") && DateTime.TryParse(Convert.ToString(formData["fromDate"]), out var fd))
                    fromDate = fd;
                if (formData.Keys.Contains("toDate") && DateTime.TryParse(Convert.ToString(formData["toDate"]), out var td))
                    toDate = td;
                if (formData.Keys.Contains("status"))
                    status = Convert.ToString(formData["status"]);

                var data = _promotionsBusiness.Search(pageIndex, pageSize, out long total, fromDate, toDate, status);

                // 🔹 Kiểm tra ngày hết hạn và đổi Status nếu cần
                foreach (var promo in data)
                {
                    if (promo.EndDate <= DateTime.Today && promo.Status == "Active")
                    {
                        promo.Status = "Expired";

                        // Nếu muốn update DB ngay để đồng bộ
                        _promotionsBusiness.Update(new PromotionsModel
                        {
                            PromotionID = promo.PromotionID,
                            PromotionName = promo.PromotionName,
                            Type = promo.Type,
                            Value = promo.Value,
                            StartDate = promo.StartDate,
                            EndDate = promo.EndDate,
                            CategoryID = promo.CategoryID,
                            Status = "Expired"
                        });
                    }
                }

                response.TotalItems = total;
                response.Data = data;
                response.Page = pageIndex;
                response.PageSize = pageSize;
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return response;
        }






    }
}
