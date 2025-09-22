using BLL;
using Model;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using BLL.Interfaces;

namespace CoreApi.Controllers
{
    [Route("api/category")]
    [ApiController]
    public class CategoryController : ControllerBase
    {
        private ICategoryBusiness _categoryBusiness;
        public CategoryController(ICategoryBusiness categoryBusiness)
        {
            _categoryBusiness = categoryBusiness;
        }

        [Route("update-category")]
        [HttpPost]
        public CategoryModel Update([FromBody]CategoryModel model)
        {
            _categoryBusiness.Update(model);
            return model;
        }

        [Route("get-by-id/{id}")]
        [HttpGet]
        public CategoryModel GetDatabyId(int id)
        {
            return _categoryBusiness.GetDatabyID(id);

        }

        [Route("create-category")]
        [HttpPost]
        public CategoryModel Create([FromBody]CategoryModel model)
        {
             _categoryBusiness.Create(model);
             return model;
        }

        [Route("delete-category")]
        [HttpPost]
        public IActionResult Delete([FromBody]int Id)
        {
            var ok = _categoryBusiness.Delete(Id);
            if (ok)
            {
                return Ok(new { message = "Đã Xoá thành công",Id });
            }
            else
            {
                return Ok(new { message = "Xoá không thành công", Id });
            }
        }
        [Route("search")]
        [HttpPost]
        public ResponseModel Search([FromBody] Dictionary<string, object> formData)
        {
            var response = new ResponseModel();

            try
            {
                var page = 1;
                var pageSize = 10;

                if (formData != null)
                {
                    if (formData.ContainsKey("page") && int.TryParse(Convert.ToString(formData["page"]), out var p) && p > 0)
                        page = p;

                    if (formData.ContainsKey("pageSize") && int.TryParse(Convert.ToString(formData["pageSize"]), out var ps) && ps > 0)
                        pageSize = ps;
                }

                // Tuỳ chọn
                int? categoryId = null;
                if (formData != null && formData.ContainsKey("CategoryID") &&
                    int.TryParse(Convert.ToString(formData["CategoryID"]), out var tmpId))
                {
                    categoryId = tmpId;
                }

                var categoryName = formData != null && formData.ContainsKey("CategoryName")
                    ? (Convert.ToString(formData["CategoryName"]) ?? string.Empty).Trim()
                    : string.Empty;

                var option = formData != null && formData.ContainsKey("option")
                    ? (Convert.ToString(formData["option"]) ?? string.Empty).Trim()
                    : string.Empty;

                long total = 0;
                var data = _categoryBusiness.Search(page, pageSize, out total, categoryId, categoryName, option);

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
