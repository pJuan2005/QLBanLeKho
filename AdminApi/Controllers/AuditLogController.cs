using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Model;
using BLL.Interfaces;

namespace AdminApi.Controllers
{
    [Authorize(Roles ="Admin")]
    [Route("api/auditlogs")]
    [ApiController]
    public class AuditLogController : ControllerBase
    {
        public IAuditLogBusiness _bus;

        public AuditLogController(IAuditLogBusiness bus)
        {
            _bus = bus;
        }

        public class AuditLogSearchRequest
        {
            public int PageIndex { get; set; } = 1;
            public int PageSize { get; set; } = 10;
            public int? UserId { get; set; }
            public string? ActionKeyword { get; set; }
            public string? Operation { get; set; }
            public DateTime? FromDate { get; set; }
            public DateTime? ToDate { get; set; }
        }

        [HttpGet("search")]
        public IActionResult Search([FromBody] AuditLogSearchRequest request)
        {
            long total;
            var data = _bus.Search(
              request.PageIndex,request.PageSize,out total,request.UserId,request.ActionKeyword??string.Empty,request.Operation??string.Empty,request.FromDate,request.ToDate);
            return Ok(new
            {
                pageIndex = request.PageIndex,
                pageSize = request.PageSize,
                total,
                data
            });
        }

        [HttpGet("get-data-by/{id}")]
        public IActionResult GetById(int id)
        {
            var log = _bus.GetDataByID(id);
            if (log == null)
                return NotFound(new { message = $"Không tìm thấy àudit log với ID  ={id}" });
            return Ok(log);
        }
    }
}
