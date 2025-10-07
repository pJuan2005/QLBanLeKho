using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using BLL;
using Model;
using System.Reflection;
using BLL.Interfaces;

namespace UserApi.Controllers
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

                int POID = 0;
                if (formData.ContainsKey("POID") && !string.IsNullOrEmpty(formData["POID"].ToString()))
                {
                    POID = Convert.ToInt32(formData["POID"]);
                }

                DateTime orderDate = DateTime.MinValue;
                if (formData.ContainsKey("OrderDate") && DateTime.TryParse(formData["OrderDate"].ToString(), out DateTime parsedDate))
                {
                    orderDate = parsedDate;
                }

                decimal totalAmount = 0;
                if (formData.ContainsKey("TotalAmount") && decimal.TryParse(formData["TotalAmount"].ToString(), out decimal parsedAmount))
                {
                    totalAmount = parsedAmount;
                }

                long total = 0;
                var data = _donMuaHangBusiness.Search(page, pageSize, out total, POID, orderDate, totalAmount);
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
