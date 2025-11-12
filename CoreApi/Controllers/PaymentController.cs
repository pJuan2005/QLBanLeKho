using AdminApi.Services.Interface;
using BLL.Interfaces;
using Microsoft.AspNetCore.Mvc;
using Model;
using System;
using System.Text.Json;

namespace CoreApi.Controllers
{
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

        [Route("create-payment-customer")]
        [HttpPost]
        public PaymentCustomerModel CreateCustomer([FromBody] PaymentCustomerModel model)
        {
            _paymentBLL.CreateCustomer(model);
            _auditLogger.Log(
                action:$"Create payment for customer by Id: {model.PaymentID}",
                entityName:"Payments",
                entityId: model.PaymentID,
                operation:"CREATE",
                details: JsonSerializer.Serialize(model)
                );
            return model;
        }
        [Route("create-payment-supplier")]
        [HttpPost]
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

        [Route("update-payment")]
        [HttpPost]
        public PaymentModel Update([FromBody] PaymentModel model)
        {
            _paymentBLL.Update(model);
            _auditLogger.Log(
                action:$"Update payment Id: {model.PaymentID}",
                entityName:"Payments",
                entityId: model.PaymentID,
                operation: "UPDATE",
                details: JsonSerializer.Serialize(model)
                );
            return model;
        }

        [Route("delete-payment/{id}")]
        [HttpDelete]
        public IActionResult Delete(int id)
        {
            _paymentBLL.Delete(id);
            _auditLogger.Log(
                action:$"Delete payment Id: {id}",
                entityName: "Payments",
                entityId: id,
                operation:"DELETE",
                details: null
                );
            return Ok(new { data = "OK" });
        }

        [Route("get-by-id/{id}")]
        [HttpGet]
        public PaymentModel GetByID(int id)
        {
            return _paymentBLL.GetByID(id);
        }

        [Route("search-payment")]
        [HttpPost]
        public ResponseModel Search([FromBody] PaymentSearchRequest request)
        {
            var response = new ResponseModel();
            try
            {
                long total = 0;
                var data = _paymentBLL.Search(
                    request.page, request.pageSize, out total,
                    request.CustomerID,request.SupplierID, request.SaleID,request.ReceiptID, request.Method, request.FromDate, request.ToDate);

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

    }
}
