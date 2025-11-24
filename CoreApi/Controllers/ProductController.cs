using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using BLL.Interfaces;
using Model;
using AdminApi.Services.Interface;
using System.Text.Json;
using Microsoft.AspNetCore.Authorization;

namespace CoreApi.Controllers
{
    [Authorize]  // bắt buộc login
    [Route("api/product")]
    [ApiController]
    public class ProductController : ControllerBase
    {
        private readonly IDProductBLL _productBLL;
        private readonly IAuditLogger _auditLogger;

        public ProductController(IDProductBLL productBLL, IAuditLogger auditLogger)
        {
            _productBLL = productBLL;
            _auditLogger = auditLogger;
        }

        private string GetImageUrl(string imagePath)
        {
            if (string.IsNullOrEmpty(imagePath)) return null;
            var baseUrl = "http://localhost:5000";
            return $"{baseUrl}/{imagePath.Replace("\\", "/")}";
        }

        // =====================================================
        // 1️⃣ GET BY ID
        // =====================================================
        [Authorize(Roles = "Admin,ThuKho,ThuNgan,KeToan")]
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
        // 2️⃣ CREATE PRODUCT
        // =====================================================
        [Authorize(Roles = "Admin,ThuKho")]
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

                _auditLogger.Log(
                    action: $"Create product: {model.ProductName} (SKU: {model.SKU})",
                    entityName: "Products",
                    entityId: model.ProductID,
                    operation: "CREATE",
                    details: JsonSerializer.Serialize(model)
                );

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
        // 3️⃣ UPDATE PRODUCT
        // =====================================================
        [Authorize(Roles = "Admin,ThuKho")]
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

                _auditLogger.Log(
                    action: $"Update product: {model.ProductName} (ID: {model.ProductID})",
                    entityName: "Products",
                    entityId: model.ProductID,
                    operation: "UPDATE",
                    details: JsonSerializer.Serialize(new { Before = exist, After = model })
                );

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
        [Authorize(Roles = "Admin")]
        [HttpDelete("delete-product/{id}")]
        public IActionResult Delete(int id)
        {
            try
            {
                var exist = _productBLL.GetDatabyID(id);
                if (exist == null)
                    return NotFound("Không tìm thấy sản phẩm.");

                _productBLL.Delete(id);

                _auditLogger.Log(
                    action: $"Delete product: {exist.ProductName} (ID: {exist.ProductID})",
                    entityName: "Products",
                    entityId: exist.ProductID,
                    operation: "DELETE",
                    details: JsonSerializer.Serialize(exist)
                );

                return Ok(new { message = "Xóa thành công!" });
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        // =====================================================
        // 5️⃣ SEARCH PRODUCT
        // =====================================================
        [Authorize(Roles = "Admin,ThuKho,ThuNgan,KeToan")]
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
