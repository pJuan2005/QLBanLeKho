using BLL.Interfaces;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Model;
using System.ComponentModel.DataAnnotations.Schema;

namespace CoreApi.Controllers
{
    [Route("api/product")]
    [ApiController]
    public class ProductController : ControllerBase
    {
        private readonly IDProductBLL _ProductBusiness;


        private void GenerateImageUrl(ProductModel product)
        {
            if (product != null && !string.IsNullOrEmpty(product.Image))
            {
                product.Image = $"Products/{product.Image}"; // mới
            }
        }



        [HttpPut("update-product/{id}")]
        public async Task<IActionResult> UpdateProduct(int id, [FromForm] ProductModel model, IFormFile? imageFile)
        {

            try
            {
                // ✅ Kiểm tra sản phẩm tồn tại
                var existing = _ProductBusiness.GetDatabyID(id);
                if (existing == null)
                    return NotFound("Không tìm thấy sản phẩm.");

                // ✅ Nếu có upload ảnh mới
                if (imageFile != null && imageFile.Length > 0)
                {
                    // Tạo thư mục nếu chưa có
                    string folderPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "Products");
                    if (!Directory.Exists(folderPath))
                        Directory.CreateDirectory(folderPath);

                    // Tạo tên file mới (tránh trùng)
                    string fileName = Path.GetFileNameWithoutExtension(imageFile.FileName)
                                     + "_" + Guid.NewGuid().ToString("N").Substring(0, 6)
                                     + Path.GetExtension(imageFile.FileName);

                    string fullPath = Path.Combine(folderPath, fileName);

                    // Lưu file
                    using (var stream = new FileStream(fullPath, FileMode.Create))
                    {
                        await imageFile.CopyToAsync(stream);
                    }

                    // Cập nhật đường dẫn ảnh trong model
                    model.Image = $"Products/{fileName}";
                }
                else
                {
                    // Nếu không chọn ảnh mới → giữ ảnh cũ
                    model.Image = existing.Image;
                }

                // ✅ Cập nhật thông tin còn lại
                model.ProductID = id;
                _ProductBusiness.Update(model);

                return Ok(new { message = "Cập nhật sản phẩm thành công!", image = model.Image });
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }




        public ProductController(IDProductBLL productBLL)
        {
            _ProductBusiness = productBLL;
        }


        [Route("create-product")]
        [HttpPost]
        public IActionResult CreateProduct([FromForm] ProductModel product, IFormFile? imageFile)
        {
            ModelState.Remove("Image");

            try
            {
                // ✅ Nếu có upload ảnh
                if (imageFile != null && imageFile.Length > 0)
                {
                    // Thư mục lưu ảnh
                    var folderPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "Products");

                    // Tạo thư mục nếu chưa tồn tại
                    if (!Directory.Exists(folderPath))
                    {
                        Directory.CreateDirectory(folderPath);
                    }

                    // Tạo tên file duy nhất tránh trùng lặp
                    var fileName = $"{Guid.NewGuid()}_{Path.GetFileName(imageFile.FileName)}";
                    var filePath = Path.Combine(folderPath, fileName);

                    // Lưu file
                    using (var stream = new FileStream(filePath, FileMode.Create))
                    {
                        imageFile.CopyTo(stream);
                    }

                    // Lưu đường dẫn tương đối vào DB
                    product.Image = $"Products/{fileName}";
                }

                // ✅ Gọi BLL để thêm vào DB
                var result = _ProductBusiness.Create(product);

                return Ok(new
                {
                    success = true,
                    message = "Thêm sản phẩm thành công!",
                    data = result
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new
                {
                    success = false,
                    message = $"Lỗi khi thêm sản phẩm: {ex.Message}"
                });
            }
        }


        [Route("update-product")]
        [HttpPost]
        public ProductModel Update([FromBody] ProductModel model)
        {
            _ProductBusiness.Update(model);
            return model;
        }

        [Route("delete-product/{id}")]
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
            var product = _ProductBusiness.GetDatabyID(id);
            GenerateImageUrl(product); // Tạo URL cho sản phẩm
            return product;
        }

        //[Route("search-product")][HttpPost] public ResponseModel Search([FromBody] Dictionary<string, object> formData) { var response = new ResponseModel(); try { var page = int.Parse(formData["page"].ToString()); var pageSize = int.Parse(formData["pageSize"].ToString()); int? IDProduct = null; if (formData.Keys.Contains("IDProduct") && !string.IsNullOrEmpty(Convert.ToString(formData["IDProduct"]))) { IDProduct = Convert.ToInt32(formData["IDProduct"]); } string ProductName = ""; if (formData.Keys.Contains("ProductName") && !string.IsNullOrEmpty(Convert.ToString(formData["ProductName"]))) { ProductName = Convert.ToString(formData["ProductName"]); } string option = ""; if (formData.Keys.Contains("option") && !string.IsNullOrEmpty(Convert.ToString(formData["option"]))) { option = Convert.ToString(formData["option"]); } long total = 0; var data = _ProductBusiness.Search(page, pageSize, out total, IDProduct, ProductName, option); response.TotalItems = total; response.Data = data; response.Page = page; response.PageSize = pageSize; } catch (Exception ex) { throw new Exception(ex.Message); } return response; }

        [Route("search-product")]
        [HttpPost]
        public ResponseModel Search([FromBody] ProductSearchRequest request)
        {
            var response = new ResponseModel();
            try
            {
                long total = 0;
                var data = _ProductBusiness.Search(request, out total);

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

