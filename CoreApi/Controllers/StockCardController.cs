using BLL.Interfaces;
using Microsoft.AspNetCore.Mvc;
using Model;
using System;
using Microsoft.AspNetCore.Authorization;

namespace CoreApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize] // bắt buộc đã login (có JWT)
    public class StockCardController : ControllerBase
    {
        private readonly IDStockCardBLL _stockCardBLL;

        public StockCardController(IDStockCardBLL stockCardBLL)
        {
            _stockCardBLL = stockCardBLL;
        }

        // ================== GET BY ID ==================
        // Xem chi tiết thẻ kho: Admin + Thủ kho + Kế toán
        [Authorize(Roles = "Admin,ThuKho,KeToan")]
        [Route("get-by-id/{id}")]
        [HttpGet]
        public StockCardModel GetByID(int id)
        {
            return _stockCardBLL.GetDatabyID(id);
        }

        // ================== CREATE ==================
        // Tạo thẻ kho: Admin + Thủ kho
        [Authorize(Roles = "Admin,ThuKho")]
        [Route("create-stockcard")]
        [HttpPost]
        public StockCardModel Create([FromBody] StockCardModel model)
        {
            _stockCardBLL.Create(model);
            return model;
        }

        // ================== UPDATE ==================
        // Cập nhật thẻ kho: Admin + Thủ kho
        [Authorize(Roles = "Admin,ThuKho")]
        [Route("update")]
        [HttpPut]
        public StockCardModel Update([FromBody] StockCardModel model)
        {
            _stockCardBLL.Update(model);
            return model;
        }

        // ================== DELETE ==================
        // Xoá thẻ kho: chỉ Admin
        [Authorize(Roles = "Admin")]
        [HttpDelete("delete/{id}")]
        public IActionResult Delete(int id)
        {
            var ok = _stockCardBLL.Delete(id);

            if (!ok)
                return NotFound(new { message = "Stockcard not found" });

            return Ok(new { message = "Delete success" });
        }

        // ================== SEARCH ==================
        // Search thẻ kho: xem được cho Admin + Thủ kho + Kế toán
        [Authorize(Roles = "Admin,ThuKho,KeToan")]
        [Route("search-stockcard")]
        [HttpPost]
        public ResponseModel Search([FromBody] StockCardSearchRequest request)
        {
            var response = new ResponseModel();
            try
            {
                long total = 0;
                var data = _stockCardBLL.Search(request, out total);

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
