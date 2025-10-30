using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using BLL;
using Model;
using System.Reflection;
using BLL.Interfaces;

namespace CoreApi.Controllers
{

    [Route("api/purchaseorder")]
    public class PurchaseOrderRepositoryController : ControllerBase
    {
        private IPurchaseOrderBusiness _purchaseOrderBusiness;

        public PurchaseOrderRepositoryController(IPurchaseOrderBusiness donMuaHangBusiness)
        {
            _purchaseOrderBusiness = donMuaHangBusiness;
        }

        [Route("create")]
        [HttpPost]
        public IActionResult Create([FromBody] List<PurchaseOrderModel> models)
        {
            _purchaseOrderBusiness.CreateMultiple(models);
            return Ok(models);
        }

        [Route("update")]
        [HttpPost]
        public PurchaseOrderModel Update([FromBody] PurchaseOrderModel model)
        {
            _purchaseOrderBusiness.Update(model);
            return model;
        }

        [Route("delete")]
        [HttpPost]
        public IActionResult Delete([FromBody] PurchaseOrderModel model)
        {
            _purchaseOrderBusiness.Delete(model);
            return Ok(new { data = "OK" });
        }

        [Route("get-by-id/{id}")]
        [HttpGet]
        public PurchaseOrderModel GetDatabyID(int id)
        {
            return _purchaseOrderBusiness.GetDatabyID(id);
        }

        [Route("search")]
        [HttpGet]
        public IActionResult Search(
            [FromQuery] decimal? minTotalAmount,
            [FromQuery] decimal? maxTotalAmount,
            [FromQuery] string status,
            [FromQuery] DateTime? fromDate,
            [FromQuery] DateTime? toDate)
        {
            try
            {
                var result = _purchaseOrderBusiness.Search(
                    minTotalAmount, maxTotalAmount, status, fromDate, toDate);

                return Ok(result);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = ex.Message });
            }
        }
    }
}
