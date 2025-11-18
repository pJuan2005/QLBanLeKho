using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using BLL.Interfaces;
using Model;
using AdminApi.Services.Interface;
using System.Text.Json;

using BLL.Interfaces;
using Microsoft.AspNetCore.Mvc;
using Model;

namespace CoreApi.Controllers
{
    [Route("api/product")]
    [ApiController]
    public class ProductController : ControllerBase
    {
        private readonly IDProductBLL _productBLL;

        public ProductController(IDProductBLL productBLL)
        {
            _productBLL = productBLL;
        }

        private string GetImageUrl(string imagePath)
        {
            if (string.IsNullOrEmpty(imagePath)) return null;
            var baseUrl = "http://localhost:5000";
            return $"{baseUrl}/{imagePath.Replace("\\", "/")}";
        }

        // =====================================================
        // 1️⃣ GET BY ID (NEW)
        // =====================================================
        [HttpGet("get-by-id/{id}")]
        public IActionResult GetById(int id)
        {
            var p = _productBLL.GetDatabyID(id);

            if (p == null)
                return NotFound("Không tìm thấy sản phẩm.");

            if (!string.IsNullOrEmpty(p.Image))
                p.Image = GetImageUrl(p.Image);

            return Ok(p);
        }

        // =====================================================
        // 2️⃣ CREATE PRODUCT (NEW)
        // =====================================================
        [HttpPost("create-product")]
        public async Task<IActionResult> Create([FromForm] ProductModel model, IFormFile? imageFile)
        {
            try
            {
                if (imageFile != null)
                {
                    string folder = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "Products");
                    if (!Directory.Exists(folder))
                        Directory.CreateDirectory(folder);

                    string fileName = $"{Guid.NewGuid()}_{imageFile.FileName}";
                    string filePath = Path.Combine(folder, fileName);

                    using var stream = new FileStream(filePath, FileMode.Create);
                    await imageFile.CopyToAsync(stream);

                    model.Image = $"Products/{fileName}";
                }

                _productBLL.Create(model);

                return Ok(new
                {
                    success = true,
                    message = "Thêm sản phẩm thành công!",
                    id = model.ProductID
                });
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        // =====================================================
        // 3️⃣ UPDATE PRODUCT (NEW)
        // =====================================================
        [HttpPut("update-product/{id}")]
        public async Task<IActionResult> Update(int id, [FromForm] ProductModel model, IFormFile? imageFile)
        {
            try
            {
                var exist = _productBLL.GetDatabyID(id);
                if (exist == null)
                    return NotFound("Không tìm thấy sản phẩm.");

                if (imageFile != null)
                {
                    string folder = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "Products");

                    if (!Directory.Exists(folder))
                        Directory.CreateDirectory(folder);

                    string fileName = $"{Guid.NewGuid()}_{imageFile.FileName}";
                    string fullPath = Path.Combine(folder, fileName);

                    using (var stream = new FileStream(fullPath, FileMode.Create))
                    {
                        await imageFile.CopyToAsync(stream);
                    }

                    model.Image = $"Products/{fileName}";
                }
                else
                {
                    model.Image = exist.Image;
                }

                model.ProductID = id;

                _productBLL.Update(model);

                return Ok(new { message = "Cập nhật sản phẩm thành công!" });
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        // =====================================================
        // 4️⃣ DELETE PRODUCT
        // =====================================================
        [HttpDelete("delete-product/{id}")]
        public IActionResult Delete(int id)
        {
            try
            {
                _productBLL.Delete(id);
                return Ok(new { message = "Xóa thành công!" });
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        // =====================================================
        // 5️⃣ SEARCH PRODUCT (NEW)
        // =====================================================
        [HttpPost("search-product")]
        public IActionResult Search([FromBody] ProductSearchRequest req)
        {
            try
            {
                long total;
                var data = _productBLL.Search(req, out total);

                foreach (var p in data)
                {
                    if (!string.IsNullOrEmpty(p.Image))
                        p.Image = GetImageUrl(p.Image);
                }

                return Ok(new
                {
                    TotalItems = total,
                    Data = data,
                    Page = req.page,
                    PageSize = req.pageSize
                });
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }
    }
}