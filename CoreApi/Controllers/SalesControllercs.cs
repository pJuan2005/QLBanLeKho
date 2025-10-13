using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using BLL;
using System.Reflection;
using BLL.Interfaces;
using Model;

namespace CoreApi.Controllers
{
    [Route("api/sales")]
    [ApiController]
    public class SalesController : ControllerBase
    {
        private ISalesBusiness _salesBusiness;

        public SalesController(ISalesBusiness salesBusiness)
        {
            _salesBusiness = salesBusiness;
        }

        [Route("create")]
        [HttpPost]
        public SalesModel Create([FromBody] SalesModel model)
        {
            _salesBusiness.Create(model);
            return model;
        }

        [Route("update")]
        [HttpPost]
        public SalesModel Update([FromBody] SalesModel model)
        {
            _salesBusiness.Update(model);
            return model;
        }

        [Route("delete")]
        [HttpPost]
        public IActionResult Delete([FromBody] SalesModel model)
        {
            _salesBusiness.Delete(model);
            return Ok(new { data = "ok" });
        }

        [Route("get-by-id/{id}")]
        [HttpGet]
        public SalesModel GetDatabyID(int id)
        {
            return _salesBusiness.GetDatabyID(id);
        }
    }
}