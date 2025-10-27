using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Model;
using System.Reflection;
using BLL.Interfaces;

namespace CoreApi.Controllers
{
    [Route("api/GoodsReceipts")]
    [ApiController]
    public class GoodsReceiptsController : ControllerBase
    {
        private IGoodsReceiptsBusiness _goodsReceiptsBusiness;

        public GoodsReceiptsController(IGoodsReceiptsBusiness goodsReceiptsBusiness)
        {
            _goodsReceiptsBusiness = goodsReceiptsBusiness;
        }

        [Route("create")]
        [HttpPost]
        public IActionResult Create([FromBody] List<GoodsReceiptsModel> models)
        {
            _goodsReceiptsBusiness.CreateMultiple(models);
            return Ok(models);
        }


        [Route("update")]
        [HttpPost]
        public GoodsReceiptsModel Update([FromBody] GoodsReceiptsModel model)
        {
            _goodsReceiptsBusiness.Update(model);
            return model;
        }

        [Route("delete")]
        [HttpPost]
        public IActionResult Delete([FromBody] GoodsReceiptsModel model)
        {
            _goodsReceiptsBusiness.Delete(model);
            return Ok(new { data = "OK" });
        }

        [Route("get-by-id/{id}")]
        [HttpGet]
        public GoodsReceiptsModel GetDatabyID(int id)
        {
            return _goodsReceiptsBusiness.GetDatabyID(id);
        }
    }
}
