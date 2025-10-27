using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using BLL;
using System.Reflection;
using BLL.Interfaces;
using Model;

namespace CoreApi.Controllers
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
        public IActionResult Create([FromBody] List<PurchaseOrderDetailsModel> models)
        {
            _PurchaseOrderDetailsBusiness.CreateMultiple(models);
            return Ok();
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
