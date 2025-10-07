using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using BLL;
using Model;
using System.Reflection;
using BLL.Interfaces;

namespace CoreApi.Controllers
{

    [Route("api/donmuahang")]
    public class DonMuaHangController : ControllerBase
    {
        private IDonMuaHangBusiness _donMuaHangBusiness;

        public DonMuaHangController(IDonMuaHangBusiness donMuaHangBusiness)
        {
            _donMuaHangBusiness = donMuaHangBusiness;
        }

        [Route("create")]
        [HttpPost]
        public DonMuaHangModel Create([FromBody] DonMuaHangModel model)
        {
            _donMuaHangBusiness.Create(model);
            return model;
        }

        [Route("update")]
        [HttpPost]
        public DonMuaHangModel Update([FromBody] DonMuaHangModel model)
        {
            _donMuaHangBusiness.Update(model);
            return model;
        }

        [Route("delete")]
        [HttpPost]
        public IActionResult Delete([FromBody] DonMuaHangModel model)
        {
            _donMuaHangBusiness.Delete(model);
            return Ok(new { data = "OK" });
        }

        [Route("get-by-id/{id}")]
        [HttpGet]
        public DonMuaHangModel GetDatabyID(int id)
        {
            return _donMuaHangBusiness.GetDatabyID(id);
        }

        [Route("search")]
        [HttpPost]
        public ResponseModel Search([FromBody] Dictionary<string, object> formData)
        {
            var response = new ResponseModel();
            try
            {
                var page = int.Parse(formData["page"].ToString());
                var pageSize = int.Parse(formData["pageSize"].ToString());

                int? SupplierID = null; // Sử dụng nullable int
                if (formData.ContainsKey("SupplierID") && !string.IsNullOrEmpty(formData["SupplierID"].ToString()))
                {
                    SupplierID = Convert.ToInt32(formData["SupplierID"]);
                }

                DateTime? orderDate = null; // Sử dụng nullable DateTime, mặc định là null nếu không cung cấp
                if (formData.ContainsKey("OrderDate") && DateTime.TryParse(formData["OrderDate"].ToString(), out DateTime parsedDate))
                {
                    orderDate = parsedDate.Date; // Gán giá trị nếu có
                }


                decimal totalAmount = 0;
                if (formData.ContainsKey("TotalAmount"))
                {
                    try
                    {
                        totalAmount = Convert.ToDecimal(formData["TotalAmount"]);
                    }
                    catch
                    {
                        totalAmount = 0; // hoặc log lỗi nếu cần
                    }
                }


                long total = 0;
                var data = _donMuaHangBusiness.Search(page, pageSize, out total, SupplierID, orderDate, totalAmount);
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
