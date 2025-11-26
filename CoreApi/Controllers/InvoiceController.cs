using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using BLL.Interfaces;
using Model;

namespace CoreApi.Controllers
{
    [Authorize] // Yêu cầu đăng nhập cho mọi endpoint
    [Route("api/invoices")]
    [ApiController]
    public class InvoiceController : ControllerBase
    {
        private readonly IInvoiceBusiness _invoiceBusiness;

        public InvoiceController(IInvoiceBusiness invoiceBusiness)
        {
            _invoiceBusiness = invoiceBusiness;
        }

        // ========== CREATE ==========
        // Chỉ Admin + Thu ngân được tạo hoá đơn
        [Authorize(Roles = "Admin,ThuNgan")]
        [HttpPost("create")]
        public InvoiceModel Create([FromBody] InvoiceModel model)
        {
            _invoiceBusiness.Create(model);
            return model;
        }

        // ========== DELETE ==========
        // Chỉ Admin được xoá hóa đơn
        [Authorize(Roles = "Admin")]
        [HttpPost("delete")]
        public IActionResult Delete([FromBody] InvoiceModel model)
        {
            _invoiceBusiness.Delete(model);
            return Ok(new { data = "ok" });
        }

        // ========== GET BY ID ==========
        // Admin + Thu ngân + Kế toán được xem hoá đơn
        [Authorize(Roles = "Admin,ThuNgan,KeToan")]
        [HttpGet("get-by-id/{id}")]
        public InvoiceModel GetDatabyID(int id)
        {
            return _invoiceBusiness.GetDatabyID(id);
        }
    }
}
