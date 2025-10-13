using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Model;
using System.Reflection;
using BLL.Interfaces;

namespace CoreApi.Controllers
{
    [Route("api/GoodsReceiptDetails")]
    [ApiController]
    public class GoodsReceiptDetailsController : ControllerBase
    {
        private IGoodsReceiptDetailsBusiness _goodsReceiptDetailsBusiness;

        public GoodsReceiptDetailsController(IGoodsReceiptDetailsBusiness goodsReceiptDetailsBusiness)
        {
            _goodsReceiptDetailsBusiness = goodsReceiptDetailsBusiness;
        }

        [Route("create")]
        [HttpPost]
        public GoodsReceiptDetailsModel Create([FromBody] GoodsReceiptDetailsModel model)
        {
            _goodsReceiptDetailsBusiness.Create(model);
            return model;
        }

        [Route("update")]
        [HttpPost]
        public GoodsReceiptDetailsModel Update([FromBody] GoodsReceiptDetailsModel model)
        {
            _goodsReceiptDetailsBusiness.Update(model);
            return model;
        }

        [Route("delete")]
        [HttpPost]
        public IActionResult Delete([FromBody] GoodsReceiptDetailsModel model)
        {
            _goodsReceiptDetailsBusiness.Delete(model);
            return Ok(new { data = "OK" });
        }

        [Route("get-by-id/{receiptID}")]
        [HttpGet]
        public GoodsReceiptDetailsModel GetDatabyID(int receiptID)
        {
            return _goodsReceiptDetailsBusiness.GetDatabyID(receiptID);
        }
    }
}
