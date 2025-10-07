using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using BLL;
using System.Reflection;
using BLL.Interfaces;
using Model;

namespace CoreApi.Controllers
{
    [Route("api/promotions")]
    public class PromotionsController : ControllerBase
    {
        private IPromotionsBusiness _promotionsBusiness;

        public PromotionsController(IPromotionsBusiness promotionsBusiness)
        {
            _promotionsBusiness = promotionsBusiness;
        }

        [Route("create")]
        [HttpPost]
        public PromotionsModel Create([FromBody] PromotionsModel model)
        {
            _promotionsBusiness.Create(model);
            return (model);
        }

        [Route("update")]
        [HttpPost]
        public PromotionsModel Update([FromBody] PromotionsModel model)
        {
            _promotionsBusiness.Update(model);
            return model;
        }

        [Route("delete")]
        [HttpPost]
        public IActionResult Delete([FromBody] PromotionsModel model)
        {
            _promotionsBusiness.Delete(model);
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
