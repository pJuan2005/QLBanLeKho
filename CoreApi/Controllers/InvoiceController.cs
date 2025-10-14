using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using BLL;
using System.Reflection;
using BLL.Interfaces;
using Model;
namespace CoreApi.Controllers
{
   
    [Route("api/invoices")]
    [ApiController]
    public class InvoiceController : ControllerBase
    {
        private IInvoiceBusiness _invoiceBusiness;

        public InvoiceController(IInvoiceBusiness invoiceBusiness)
        {
            _invoiceBusiness = invoiceBusiness;
        }

        [Route("create")]
        [HttpPost]
        public InvoiceModel Create([FromBody] InvoiceModel model)
        {
            _invoiceBusiness.Create(model);
            return model;
        }

      

        [Route("delete")]
        [HttpPost]
        public IActionResult Delete([FromBody] InvoiceModel model)
        {
            _invoiceBusiness.Delete(model);
            return Ok(new { data = "ok" });
        }

        [Route("get-by-id/{id}")]
        [HttpGet]
        public InvoiceModel GetDatabyID(int id)
        {
            return _invoiceBusiness.GetDatabyID(id);
        }
    }
}
