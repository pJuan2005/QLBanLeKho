using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using BLL.Interfaces;
using Model;
using AdminApi.Services.Interface;
using System.Text.Json;

namespace CoreApi.Controllers
{
    [Route("api/product")]
    [ApiController]
    public class ProductController : ControllerBase
    {
        private readonly IDProductBLL _ProductBusiness;
        private readonly IAuditLogger _auditLogger;

        public ProductController(IDProductBLL productBLL, IAuditLogger auditLogger)
        {
            _ProductBusiness = productBLL;
            _auditLogger = auditLogger;
        }

        // PUT /api/product/update-product/{id}
        [HttpPut("update-product/{id}")]
        public async Task<IActionResult> UpdateProduct(int id, [FromForm] ProductModel model, IFormFile? imageFile)
        {
            try
            {
                var existing = _ProductBusiness.GetDatabyID(id);
                if (existing == null)
                    return NotFound("Không tìm thấy sản phẩm.");

                // ảnh nhị phân (bach2.0)
                if (imageFile != null && imageFile.Length > 0)
                {
                    using var ms = new MemoryStream();
                    await imageFile.CopyToAsync(ms);
                    model.ImageData = ms.ToArray();
                }
                else
                {
                    // giữ ảnh cũ
                    model.ImageData = existing.ImageData;
                }

                model.ProductID = id;

                _ProductBusiness.Update(model);

                // Audit log (giữ từ dev, chi tiết serialize)
                _auditLogger.Log(
                    action: "Update",
                    entityName: "Products",
                    entityId: model.ProductID,
                    operation: "UPDATE",
                    details: JsonSerializer.Serialize(new
                    {
                        ProductID = model.ProductID,
                        Old = new { existing.ProductName, existing.UnitPrice },
                        New = new { model.ProductName, model.UnitPrice }
                    })
                );

                return Ok(new { message = "Cập nhật sản phẩm thành công!" });
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        // POST /api/product/create-product
        [HttpPost("create-product")]
        public async Task<IActionResult> CreateProduct([FromForm] ProductModel product, IFormFile? imageFile)
        {
            try
            {
                if (imageFile != null && imageFile.Length > 0)
                {
                    using var ms = new MemoryStream();
                    await imageFile.CopyToAsync(ms);
                    product.ImageData = ms.ToArray(); // lưu ảnh dạng nhị phân (bach2.0)
                }

                // BUG cũ: gọi Create 2 lần → đã sửa còn 1 lần
                var result = _ProductBusiness.Create(product); // nếu Create trả về ID hoặc model, dùng result theo signature thực tế

                _auditLogger.Log(
                    action: "Create",
                    entityName: "Products",
                    entityId: product.ProductID, // hoặc result.ProductID / result (nếu Create trả về ID)
                    operation: "CREATE",
                    details: JsonSerializer.Serialize(new
                    {
                        product.ProductName,
                        product.SKU,
                        product.UnitPrice
                    })
                );

                return Ok(new
                {
                    success = true,
                    message = "Thêm sản phẩm thành công!",
                    data = result
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }

        // DELETE /api/product/delete-product/{id}
        [HttpDelete("delete-product/{id}")]
        public IActionResult Delete(int id)
        {
            try
            {
                var ok = _ProductBusiness.Delete(id);

                // Audit sau khi xóa
                _auditLogger.Log(
                    action: "Delete",
                    entityName: "Products",
                    entityId: id,
                    operation: "DELETE",
                    details: null
                );

                return Ok(new { success = ok });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }

        // GET /api/product/get-by-id/{id}
        [HttpGet("get-by-id/{id}")]
        public IActionResult GetDatabyID(int id)
        {
            var product = _ProductBusiness.GetDatabyID(id);
            if (product == null) return NotFound();

            string? base64 = product.ImageData != null && product.ImageData.Length > 0
                ? $"data:image/png;base64,{Convert.ToBase64String(product.ImageData)}"
                : null;

            return Ok(new
            {
                product.ProductID,
                product.ProductName,
                product.SKU,
                product.Barcode,
                product.CategoryID,
                product.UnitPrice,
                product.Unit,
                product.MinStock,
                product.Quantity,
                product.VATRate,
                product.Status,
                ImageBase64 = base64
            });
        }

        // POST /api/product/search-product
        [Route("search-product")]
        [HttpPost]
        public ResponseModel Search([FromBody] ProductSearchRequest request)
        {
            var response = new ResponseModel();
            try
            {
                long total = 0;
                var data = _ProductBusiness.Search(request, out total);

                // bơm base64 cho FE (bach2.0)
                foreach (var p in data)
                {
                    if (p.ImageData != null && p.ImageData.Length > 0)
                    {
                        p.ImageBase64 = $"data:image/png;base64,{Convert.ToBase64String(p.ImageData)}";
                    }
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
