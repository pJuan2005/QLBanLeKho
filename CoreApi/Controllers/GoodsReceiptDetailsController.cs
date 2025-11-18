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
        public IActionResult Create([FromBody] List<GoodsReceiptDetailsModel> models)
        {
            _goodsReceiptDetailsBusiness.CreateMultiple(models);
            return Ok(models);
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
        public IEnumerable<GoodsReceiptDetailsModel> GetDatabyID(int receiptID)
        {
            return _goodsReceiptDetailsBusiness.GetDatabyID(receiptID);
        }

    }
}
