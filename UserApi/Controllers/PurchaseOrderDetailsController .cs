using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using BLL;
using System.Reflection;
using BLL.Interfaces;
using Model;

namespace UserApi.Controllers
{
    [Route("api/purchaseorderdetails")]
   
    public class PurchaseOrderDetailsController : ControllerBase
    {
        private IPurchaseOrderDetailsBusiness _PurchaseOrderDetailsBusiness;

        public PurchaseOrderDetailsController(IPurchaseOrderDetailsBusiness purchaseOrderDetailsBusiness)
        {
            _PurchaseOrderDetailsBusiness = purchaseOrderDetailsBusiness;
        }

        [Route("create")]
        [HttpPost]
        public PurchaseOrderDetailsModel Create([FromBody] PurchaseOrderDetailsModel model)
        {
            _PurchaseOrderDetailsBusiness.Create(model);
            return model;
        }

        [Route("update")]
        [HttpPost]
        public PurchaseOrderDetailsModel Update([FromBody] PurchaseOrderDetailsModel model)
        {
            _PurchaseOrderDetailsBusiness.Update(model);
            return model;

        }

        [Route("delete")]
        [HttpPost]
        public IActionResult Delete([FromBody] PurchaseOrderDetailsModel model)
        {
            _PurchaseOrderDetailsBusiness.Delete(model);
            return Ok(new { data = "ok" });
        }

        [Route("get-by-id/{poid}")]
        [HttpGet]
        public PurchaseOrderDetailsModel GetDatabyID(int poid, int productId)
        {
            return _PurchaseOrderDetailsBusiness.GetDatabyID(poid, productId);
        }
    }
}
