using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using BLL;
using System.Reflection;
using BLL.Interfaces;
using Model;
using Microsoft.AspNetCore.Authorization;

namespace CoreApi.Controllers
{
    [Authorize(Roles = "Admin,ThuKho,KeToan")]
    [Route("api/purchaseorderdetails")]
    [ApiController]
    public class PurchaseOrderDetailsController : ControllerBase
    {
        private readonly IPurchaseOrderDetailsBusiness _PurchaseOrderDetailsBusiness;

        public PurchaseOrderDetailsController(IPurchaseOrderDetailsBusiness purchaseOrderDetailsBusiness)
        {
            _PurchaseOrderDetailsBusiness = purchaseOrderDetailsBusiness;
        }

        // ================= CREATE MULTIPLE =================
        [HttpPost("create")]
        public IActionResult Create([FromBody] List<PurchaseOrderDetailsModel> models)
        {
            _PurchaseOrderDetailsBusiness.CreateMultiple(models);
            return Ok(models);
        }

        // ================= DELETE ONE ROW =================
        [HttpPost("delete")]
        public IActionResult Delete([FromBody] PurchaseOrderDetailsModel model)
        {
            _PurchaseOrderDetailsBusiness.Delete(model);
            return Ok(new { data = "ok" });
        }

        // ================= GET BY POID =================
        [HttpGet("get-by-poid/{poid}")]
        public List<PurchaseOrderDetailsModel> GetByPOID(int poid)
        {
            return _PurchaseOrderDetailsBusiness.GetByPOID(poid);
        }
    }
}
