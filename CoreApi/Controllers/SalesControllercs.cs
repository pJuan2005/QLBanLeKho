using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using BLL;
using System.Reflection;
using BLL.Interfaces;
using Model;
using AdminApi.Services.Interface;
using System.Text.Json;

namespace CoreApi.Controllers
{
    [Route("api/sales")]
    [ApiController]
    public class SalesController : ControllerBase
    {
        private ISalesBusiness _salesBusiness;
        private IAuditLogger _auditLogger;

        public SalesController(ISalesBusiness salesBusiness, IAuditLogger auditLogger)
        {
            _salesBusiness = salesBusiness;
            _auditLogger = auditLogger;
        }

        [Route("create")]
        [HttpPost]
        public SalesModel Create([FromBody] SalesModel model)
        {
            _salesBusiness.Create(model);
            _auditLogger.Log(
                action: $"Create sales Id: {model.SaleID}",
                entityName: "Sales",
                entityId: model.SaleID,
                operation: "CREATE",
                details: JsonSerializer.Serialize(model)
                );
            return model;
        }

        [Route("update")]
        [HttpPost]
        public SalesModel Update([FromBody] SalesModel model)
        {
            _salesBusiness.Update(model);
            _auditLogger.Log(
                action: $"Update sales Id: {model.SaleID}",
                entityName:"Sales",
                entityId: model.SaleID,
                operation: "UPDATE",
                details: JsonSerializer.Serialize(model)
                );
            return model;
        }

        [Route("delete")]
        [HttpPost]
        public IActionResult Delete([FromBody] SalesModel model)
        {
            _salesBusiness.Delete(model);
            _auditLogger.Log(
                action: $"Delete sales Id: {model.SaleID}",
                entityName:"Sales",
                entityId: model.SaleID,
                operation: "DELETE",
                details: null
                );
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