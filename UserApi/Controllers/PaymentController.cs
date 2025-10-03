using BLL.Interfaces;
using Microsoft.AspNetCore.Mvc;
using Model;

namespace CoreApi.Controllers
{
    [Route("api/payment")]
    [ApiController]
    public class PaymentController : ControllerBase
    {
        private readonly IDPaymentBLL _paymentBusiness;

        public PaymentController(IDPaymentBLL paymentBusiness)
        {
            _paymentBusiness = paymentBusiness;
        }

        // ✅ Thêm mới thanh toán
        [Route("create-payment")]
        [HttpPost]
        public PaymentModel Create([FromBody] PaymentModel model)
        {
            _paymentBusiness.Create(model);
            return model;
        }

        // ✅ Cập nhật thanh toán
        [Route("update-payment")]
        [HttpPost]
        public PaymentModel Update([FromBody] PaymentModel model)
        {
            _paymentBusiness.Update(model);
            return model;
        }

        // ✅ Xoá thanh toán
        [Route("delete-payment/{id}")]
        [HttpDelete]
        public IActionResult Delete(int id)
        {
            _paymentBusiness.Delete(id);
            return Ok(new { data = "OK" });
        }

        // ✅ Lấy thanh toán theo ID
        [Route("get-by-id/{id}")]
        [HttpGet]
        public PaymentModel GetDatabyID(int id)
        {
            return _paymentBusiness.GetDatabyID(id);
        }

        // ✅ Tìm kiếm & phân trang

        [Route("search-payment")]
        [HttpPost]
        public ResponseModel Search([FromBody] PaymentSearchRequest request)
        {
            var response = new ResponseModel();
            try
            {
                long total = 0;
                var data = _paymentBusiness.Search(
                    request.page,
                    request.pageSize,
                    out total,
                    request.PaymentID,
                    request.CustomerID,
                    request.SupplierID,
                    request.Method,
                    request.option
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
    }
}
