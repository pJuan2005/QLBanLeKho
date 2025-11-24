using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using BLL;
using System.Reflection;
using BLL.Interfaces;
using Model;
using Microsoft.AspNetCore.Authorization;

namespace CoreApi.Controllers
{
    [Route("api/salesitem")]
    [ApiController]
    [Authorize] // bắt buộc login
    public class SalesItemController : ControllerBase
    {
        private ISalesItemBusiness _salesItemBusiness;

        public SalesItemController(ISalesItemBusiness salesItemBusiness)
        {
            _salesItemBusiness = salesItemBusiness;
        }

        // ================= CREATE =================
        // Thêm chi tiết bán hàng → ThuNgan & Admin
        [Authorize(Roles = "Admin,ThuNgan")]
        [Route("create")]
        [HttpPost]
        public IActionResult Create([FromBody] List<SalesItemModel> models)
        {
            _salesItemBusiness.CreateMultiple(models);
            return Ok(models);
        }

        // ================= DELETE =================
        // Xoá chi tiết đơn hàng → chỉ Admin để tránh xoá nhầm
        [Authorize(Roles = "Admin")]
        [Route("delete")]
        [HttpPost]
        public IActionResult Delete([FromBody] SalesItemModel model)
        {
            _salesItemBusiness.Delete(model);
            return Ok(new { data = "ok" });
        }

        // ================= GET BY ID =================
        // Ai cũng được xem: Admin, ThuNgan, KeToan
        [Authorize(Roles = "Admin,ThuNgan,KeToan")]
        [Route("get-by-id/{saleID}/{productID}")]
        [HttpGet]
        public SalesItemModel GetDatabyID(int saleID, int productID)
        {
            return _salesItemBusiness.GetDatabyID(saleID, productID);
        }
    }
}
