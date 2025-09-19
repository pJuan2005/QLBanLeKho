using BLL.Interfaces;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Model;

namespace CoreApi.Controllers
{
    [Route("api/sanpham")]
    [ApiController]
    public class ProductController : ControllerBase
    {
        private readonly IDProductBLL _ProductBusiness;

        public ProductController(IDProductBLL sanPhamBusiness)
        {
            _ProductBusiness = sanPhamBusiness;
        }

        [Route("create-sanpham")]
        [HttpPost]
        public ProductModel Create([FromBody] ProductModel model)
        {
            _ProductBusiness.Create(model);
            return model;
        }

        [Route("update-sanpham")]
        [HttpPost]
        public ProductModel Update([FromBody] ProductModel model)
        {
            _ProductBusiness.Update(model);
            return model;
        }

        [Route("delete-sanpham/{id}")]
        [HttpDelete]
        public IActionResult Delete(int id)
        {
            _ProductBusiness.Delete(id);
            return Ok(new { data = "OK" });
        }

        [Route("get-by-id/{id}")]
        [HttpGet]
        public ProductModel GetDatabyID(int id)
        {
            return _ProductBusiness.GetDatabyID(id);
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

                int? IDProduct = null;
                if (formData.Keys.Contains("IDProduct") && !string.IsNullOrEmpty(Convert.ToString(formData["IDProduct"])))
                {
                    IDProduct = Convert.ToInt32(formData["IDProduct"]);
                }

                string ProductName = "";
                if (formData.Keys.Contains("ProductName") && !string.IsNullOrEmpty(Convert.ToString(formData["ProductName"])))
                {
                    ProductName = Convert.ToString(formData["ProductName"]);
                }

                string option = "";
                if (formData.Keys.Contains("option") && !string.IsNullOrEmpty(Convert.ToString(formData["option"])))
                {
                    option = Convert.ToString(formData["option"]);
                }

                long total = 0;
                var data = _ProductBusiness.Search(page, pageSize, out total, IDProduct, ProductName, option);

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

