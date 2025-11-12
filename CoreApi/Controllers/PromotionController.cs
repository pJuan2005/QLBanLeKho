using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using BLL;
using System.Reflection;
using BLL.Interfaces;
using Model;
using AdminApi.Services.Interface;
using System.Text.Json;

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


    }
}
