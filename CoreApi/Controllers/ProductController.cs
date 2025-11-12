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


        [HttpPut("update-product/{id}")]
        public async Task<IActionResult> UpdateProduct(int id, [FromForm] ProductModel model, IFormFile? imageFile)
        {
            try
            {
                var existing = _ProductBusiness.GetDatabyID(id);
                if (existing == null)
                    return NotFound("Không tìm thấy sản phẩm.");

                if (imageFile != null && imageFile.Length > 0)
                {
                    using (var ms = new MemoryStream())
                    {
                        await imageFile.CopyToAsync(ms);
                        model.ImageData = ms.ToArray();
                    }
                }
                else
                {
                    model.ImageData = existing.ImageData; // Giữ ảnh cũ
                }

                model.ProductID = id;
                _ProductBusiness.Update(model);
                return Ok(new { message = "Cập nhật thành công!" });
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


        [HttpPost("create-product")]
        public async Task<IActionResult> CreateProduct([FromForm] ProductModel product, IFormFile? imageFile)
        {
            try
            {
                if (imageFile != null && imageFile.Length > 0)
                {
                    using (var ms = new MemoryStream())
                    {
                        await imageFile.CopyToAsync(ms);
                        product.ImageData = ms.ToArray(); // 🧠 Lưu ảnh dạng nhị phân
                    }
                }

                _ProductBusiness.Create(product);
                return Ok(new { success = true, message = "Thêm sản phẩm thành công!" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }





        [HttpDelete("delete-product/{id}")]
        public IActionResult Delete(int id)
        {
            try
            {
                var ok = _ProductBusiness.Delete(id);
                return Ok(new { success = true });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message }); // <-- thấy lỗi thật
            }
        }






        [HttpGet("get-by-id/{id}")]
        public IActionResult GetDatabyID(int id)
        {
            var product = _ProductBusiness.GetDatabyID(id);
            if (product == null) return NotFound();

            string base64 = product.ImageData != null
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

