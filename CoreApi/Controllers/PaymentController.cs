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
        [Route("search")]
        [HttpPost]
        public ResponseModel Search([FromBody] Dictionary<string, object> formData)
        {
            var response = new ResponseModel();
            try
            {
                var page = int.Parse(formData["page"].ToString());
                var pageSize = int.Parse(formData["pageSize"].ToString());

                int? PaymentID = null;
                if (formData.Keys.Contains("PaymentID") && !string.IsNullOrEmpty(Convert.ToString(formData["PaymentID"])))
                {
                    PaymentID = Convert.ToInt32(formData["PaymentID"]);
                }

                int? CustomerID = null;
                if (formData.Keys.Contains("CustomerID") && !string.IsNullOrEmpty(Convert.ToString(formData["CustomerID"])))
                {
                    CustomerID = Convert.ToInt32(formData["CustomerID"]);
                }

                int? SupplierID = null;
                if (formData.Keys.Contains("SupplierID") && !string.IsNullOrEmpty(Convert.ToString(formData["SupplierID"])))
                {
                    SupplierID = Convert.ToInt32(formData["SupplierID"]);
                }

                DateTime? FromDate = null;
                if (formData.Keys.Contains("FromDate") && !string.IsNullOrEmpty(Convert.ToString(formData["FromDate"])))
                {
                    FromDate = Convert.ToDateTime(formData["FromDate"]);
                }

                DateTime? ToDate = null;
                if (formData.Keys.Contains("ToDate") && !string.IsNullOrEmpty(Convert.ToString(formData["ToDate"])))
                {
                    ToDate = Convert.ToDateTime(formData["ToDate"]);
                }

                string Method = "";
                if (formData.Keys.Contains("Method") && !string.IsNullOrEmpty(Convert.ToString(formData["Method"])))
                {
                    Method = Convert.ToString(formData["Method"]);
                }

                string option = "";
                if (formData.Keys.Contains("option") && !string.IsNullOrEmpty(Convert.ToString(formData["option"])))
                {
                    option = Convert.ToString(formData["option"]);
                }

                long total = 0;
                var data = _paymentBusiness.Search(page, pageSize, out total,
                                                   PaymentID, CustomerID, SupplierID,
                                                   FromDate, ToDate, Method, option);

                response.TotalItems = total;
                response.Data = data;
                response.Page = page;
                response.PageSize = pageSize;
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
            return response;
        }
    }
}
