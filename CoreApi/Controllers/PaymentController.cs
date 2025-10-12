using BLL.Interfaces;
using Microsoft.AspNetCore.Mvc;
using Model;
using System;

namespace CoreApi.Controllers
{
    [Route("api/payments")]
    [ApiController]
    public class PaymentController : ControllerBase
    {
        private readonly IDPaymentBLL _paymentBLL;

        public PaymentController(IDPaymentBLL paymentBLL)
        {
            _paymentBLL = paymentBLL;
        }

        [Route("create-payment-customer")]
        [HttpPost]
        public PaymentCustomerModel CreateCustomer([FromBody] PaymentCustomerModel model)
        {
            _paymentBLL.CreateCustomer(model);
            return model;
        }
        [Route("create-payment-supplier")]
        [HttpPost]
        public PaymentSupplierModel CreateSupplier([FromBody] PaymentSupplierModel model)
        {
            _paymentBLL.CreateSupplier(model);
            return model;
        }

        [Route("update-payment")]
        [HttpPost]
        public PaymentModel Update([FromBody] PaymentModel model)
        {
            _paymentBLL.Update(model);
            return model;
        }

        [Route("delete-payment/{id}")]
        [HttpDelete]
        public IActionResult Delete(int id)
        {
            _paymentBLL.Delete(id);
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
                    request.CustomerID,request.SupplierID, request.SaleID, request.Method, request.FromDate, request.ToDate);

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
