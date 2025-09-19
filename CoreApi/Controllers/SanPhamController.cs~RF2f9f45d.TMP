using BLL.Interfaces;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Model;

namespace CoreApi.Controllers
{
    [Route("api/sanpham")]
    [ApiController]
    public class SanPhamController : ControllerBase
    {
        private readonly IDSanPhamBLL _sanPhamBusiness;

        public SanPhamController(IDSanPhamBLL sanPhamBusiness)
        {
            _sanPhamBusiness = sanPhamBusiness;
        }

        [Route("create-sanpham")]
        [HttpPost]
        public SanPhamModel Create([FromBody] SanPhamModel model)
        {
            _sanPhamBusiness.Create(model);
            return model;
        }

        [Route("update-sanpham")]
        [HttpPost]
        public SanPhamModel Update([FromBody] SanPhamModel model)
        {
            _sanPhamBusiness.Update(model);
            return model;
        }

        [Route("delete-sanpham/{id}")]
        [HttpDelete]
        public IActionResult Delete(int id)
        {
            _sanPhamBusiness.Delete(id);
            return Ok(new { data = "OK" });
        }

        [Route("get-by-id/{id}")]
        [HttpGet]
        public SanPhamModel GetDatabyID(int id)
        {
            return _sanPhamBusiness.GetDatabyID(id);
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

                int? MaSanPham = null;
                if (formData.Keys.Contains("MaSanPham") && !string.IsNullOrEmpty(Convert.ToString(formData["MaSanPham"])))
                {
                    MaSanPham = Convert.ToInt32(formData["MaSanPham"]);
                }

                string TenSanPham = "";
                if (formData.Keys.Contains("TenSanPham") && !string.IsNullOrEmpty(Convert.ToString(formData["TenSanPham"])))
                {
                    TenSanPham = Convert.ToString(formData["TenSanPham"]);
                }

                string option = "";
                if (formData.Keys.Contains("option") && !string.IsNullOrEmpty(Convert.ToString(formData["option"])))
                {
                    option = Convert.ToString(formData["option"]);
                }

                long total = 0;
                var data = _sanPhamBusiness.Search(page, pageSize, out total, MaSanPham, TenSanPham, option);

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

