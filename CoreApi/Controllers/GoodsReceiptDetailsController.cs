using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Model;
using BLL.Interfaces;

namespace CoreApi.Controllers
{
    [Authorize] // yêu cầu phải đăng nhập trước
    [Route("api/GoodsReceiptDetails")]
    [ApiController]
    public class GoodsReceiptDetailsController : ControllerBase
    {
        private readonly IGoodsReceiptDetailsBusiness _goodsReceiptDetailsBusiness;

        public GoodsReceiptDetailsController(IGoodsReceiptDetailsBusiness goodsReceiptDetailsBusiness)
        {
            _goodsReceiptDetailsBusiness = goodsReceiptDetailsBusiness;
        }

        // ========== CREATE MULTIPLE ==========
        [Authorize(Roles = "Admin,ThuKho")]
        [HttpPost("create")]
        public IActionResult Create([FromBody] List<GoodsReceiptDetailsModel> models)
        {
            _goodsReceiptDetailsBusiness.CreateMultiple(models);
            return Ok(models);
        }

        // ========== DELETE ==========
        [Authorize(Roles = "Admin,ThuKho")]
        [HttpPost("delete")]
        public IActionResult Delete([FromBody] GoodsReceiptDetailsModel model)
        {
            _goodsReceiptDetailsBusiness.Delete(model);
            return Ok(new { data = "OK" });
        }

        // ========== GET DETAILS BY ReceiptID ==========
        [Authorize(Roles = "Admin,ThuKho,KeToan")]
        [HttpGet("get-by-id/{receiptID}")]
        public IEnumerable<GoodsReceiptDetailsModel> GetDatabyID(int receiptID)
        {
            return _goodsReceiptDetailsBusiness.GetDatabyID(receiptID);
        }
    }
}
