using AdminApi.Services.Interface;
using BLL.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Model;
using System;
using System.Text.Json;

namespace CoreApi.Controllers
{
    [Authorize] // tất cả endpoint trong controller này đều yêu cầu login
    [Route("api/payments")]
    [ApiController]
    public class PaymentController : ControllerBase
    {
        private readonly IDPaymentBLL _paymentBLL;
        private readonly IAuditLogger _auditLogger;

        public PaymentController(IDPaymentBLL paymentBLL, IAuditLogger auditLogger)
        {
            _paymentBLL = paymentBLL;
            _auditLogger = auditLogger;
        }

        // ========== 1. Tạo payment cho KH (AR) ==========
        // ThuNgan + KeToan + Admin đều có thể thu tiền khách
        [Authorize(Roles = "Admin,ThuNgan,KeToan")]
        [HttpPost("create-payment-customer")]
        public PaymentCustomerModel CreateCustomer([FromBody] PaymentCustomerModel model)
        {
            _paymentBLL.CreateCustomer(model);
            _auditLogger.Log(
                action: $"Create payment for customer by Id: {model.PaymentID}",
                entityName: "Payments",
                entityId: model.PaymentID,
                operation: "CREATE",
                details: JsonSerializer.Serialize(model)
            );
            return model;
        }

        // ========== 2. Tạo payment cho NCC (AP) ==========
        // Thường chỉ KeToan + Admin mới được trả tiền NCC
        [Authorize(Roles = "Admin,KeToan")]
        [HttpPost("create-payment-supplier")]
        public PaymentSupplierModel CreateSupplier([FromBody] PaymentSupplierModel model)
        {
            _paymentBLL.CreateSupplier(model);
            _auditLogger.Log(
                action: $"Create payment for supplier by Id: {model.PaymentID}",
                entityName: "Payments",
                entityId: model.PaymentID,
                operation: "CREATE",
                details: JsonSerializer.Serialize(model)
            );
            return model;
        }

        // ========== 3. Cập nhật payment ==========
        // Hạn chế: Admin + KeToan
        [Authorize(Roles = "Admin,KeToan")]
        [HttpPost("update-payment")]
        public PaymentModel Update([FromBody] PaymentModel model)
        {
            _paymentBLL.Update(model);
            _auditLogger.Log(
                action: $"Update payment Id: {model.PaymentID}",
                entityName: "Payments",
                entityId: model.PaymentID,
                operation: "UPDATE",
                details: JsonSerializer.Serialize(model)
            );
            return model;
        }

        // ========== 4. Xoá payment ==========
        // Rất nhạy cảm → chỉ Admin
        [Authorize(Roles = "Admin")]
        [HttpDelete("delete-payment/{id}")]
        public IActionResult Delete(int id)
        {
            _paymentBLL.Delete(id);
            _auditLogger.Log(
                action: $"Delete payment Id: {id}",
                entityName: "Payments",
                entityId: id,
                operation: "DELETE",
                details: null
            );
            return Ok(new { data = "OK" });
        }

        // ========== 5. Xem chi tiết 1 payment ==========
        // Admin + ThuNgan + KeToan đều cần xem được
        [Authorize(Roles = "Admin,ThuNgan,KeToan")]
        [HttpGet("get-by-id/{id}")]
        public PaymentModel GetByID(int id)
        {
            return _paymentBLL.GetByID(id);
        }

        // ========== 6. Search payments (lọc theo KH/NCC/hoá đơn...) ==========
        // Xem lịch sử thanh toán → Admin + ThuNgan + KeToan
        [Authorize(Roles = "Admin,ThuNgan,KeToan")]
        [HttpPost("search-payment")]
        public ResponseModel Search([FromBody] PaymentSearchRequest request)
        {
            var response = new ResponseModel();
            try
            {
                long total = 0;
                var data = _paymentBLL.Search(
                    request.page,
                    request.pageSize,
                    out total,
                    request.CustomerID,
                    request.SupplierID,
                    request.SaleID,
                    request.ReceiptID,
                    request.Method,
                    request.FromDate,
                    request.ToDate
                );

                response.TotalItems = total;
                response.Data = data;
                response.Page = request.page;
                response.PageSize = request.pageSize;
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
            return response;
        }

        // ============= 7. AR: danh sách hoá đơn KH còn nợ =============
        // Màn hình công nợ khách: ThuNgan thu tiền + KeToan + Admin
        [Authorize(Roles = "Admin,ThuNgan,KeToan")]
        [HttpPost("ar-open-invoices")]
        public ResponseModel GetArOpenInvoices([FromBody] OpenPaymentSearchRequest request)
        {
            var response = new ResponseModel();
            try
            {
                int page = request.page <= 0 ? 1 : request.page;
                int pageSize = request.pageSize <= 0 ? 10 : request.pageSize;
                string search = request.search ?? string.Empty;

                long total = 0;
                var data = _paymentBLL.GetArOpenInvoices(
                    page, pageSize, out total,
                    search, request.FromDate, request.ToDate
                );

                response.Page = page;
                response.PageSize = pageSize;
                response.TotalItems = total;
                response.Data = data;

                return response;
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
        }

        // ============= 8. AP: danh sách phiếu nhập còn nợ NCC =============
        // Màn hình công nợ NCC: KeToan + Admin
        [Authorize(Roles = "Admin,KeToan")]
        [HttpPost("ap-open-bills")]
        public ResponseModel GetApOpenBills([FromBody] OpenPaymentSearchRequest request)
        {
            var response = new ResponseModel();
            try
            {
                int page = request.page <= 0 ? 1 : request.page;
                int pageSize = request.pageSize <= 0 ? 10 : request.pageSize;
                string search = request.search ?? string.Empty;

                long total = 0;
                var data = _paymentBLL.GetApOpenBills(
                    page, pageSize, out total,
                    search, request.FromDate, request.ToDate
                );

                response.Page = page;
                response.PageSize = pageSize;
                response.TotalItems = total;
                response.Data = data;

                return response;
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
        }
    }
}
