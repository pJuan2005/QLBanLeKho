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


        private string GetImageUrl(string imagePath)
        {
            if (string.IsNullOrEmpty(imagePath)) return null;
            var gatewayUrl = "http://localhost:5000"; // 👈 đường dẫn Gateway
            return $"{gatewayUrl}/{imagePath.Replace("\\", "/")}";
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
                if (imageFile != null && imageFile.Length > 0)
                {
                    // 🗂 1️⃣ Đường dẫn cũ (backend)
                    string oldPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "Products");

                    // 🗂 2️⃣ Đường dẫn mới (frontend)
                    string newPath = @"C:\Users\ADMIN\OneDrive\Desktop\QuanLyKho\bách\QLBanLeKho\Fontend\Shared\img\Products";

                    // ✅ Tạo 2 thư mục nếu chưa có
                    if (!Directory.Exists(oldPath))
                        Directory.CreateDirectory(oldPath);
                    if (!Directory.Exists(newPath))
                        Directory.CreateDirectory(newPath);

                    // ✅ Làm sạch tên file và thêm GUID tránh trùng
                    string safeFileName = Path.GetFileNameWithoutExtension(imageFile.FileName)
                        .Replace(" ", "_")
                        .Replace("đ", "d").Replace("Đ", "D")
                        .Replace("á", "a").Replace("à", "a").Replace("ạ", "a").Replace("ã", "a").Replace("ả", "a")
                        .Replace("é", "e").Replace("è", "e").Replace("ẹ", "e").Replace("ẽ", "e").Replace("ẻ", "e")
                        .Replace("ó", "o").Replace("ò", "o").Replace("ọ", "o").Replace("õ", "o").Replace("ỏ", "o")
                        .Replace("ú", "u").Replace("ù", "u").Replace("ụ", "u").Replace("ũ", "u").Replace("ủ", "u")
                        .Replace("í", "i").Replace("ì", "i").Replace("ị", "i").Replace("ĩ", "i").Replace("ỉ", "i")
                        .Replace("ý", "y").Replace("ỳ", "y").Replace("ỵ", "y").Replace("ỹ", "y").Replace("ỷ", "y");

                    string fileName = $"{Guid.NewGuid()}_{safeFileName}{Path.GetExtension(imageFile.FileName)}";

                    // ✅ Lưu file vào thư mục cũ
                    string oldFile = Path.Combine(oldPath, fileName);
                    using (var stream = new FileStream(oldFile, FileMode.Create))
                    {
                        imageFile.CopyTo(stream);
                    }

                    // ✅ Lưu file vào thư mục mới
                    string newFile = Path.Combine(newPath, fileName);
                    using (var stream = new FileStream(newFile, FileMode.Create))
                    {
                        imageFile.CopyTo(stream);
                    }

                    // ✅ Lưu đường dẫn tương đối vào DB (vẫn dùng link backend)
                    product.Image = $"Products/{fileName}";
                }

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
            
            product.Image = GetImageUrl(product.Image);
            return product;
        }


        [Route("search-product")]
        [HttpPost]
        public ResponseModel Search([FromBody] ProductSearchRequest request)
        {
            var response = new ResponseModel();
            try
            {
                long total = 0;
                var data = _ProductBusiness.Search(request, out total);



                foreach (var p in data)
                {
                    if (!string.IsNullOrEmpty(p.Image))
                        p.Image = GetImageUrl(p.Image);
                }

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

