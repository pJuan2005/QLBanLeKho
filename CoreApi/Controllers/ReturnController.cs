using BLL.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Model;
using System;

namespace CoreApi.Controllers
{
    [Route("api/return")]
    [ApiController]
    public class ReturnController : ControllerBase
    {
        private readonly IReturnBLL _bll;
        public ReturnController(IReturnBLL bll)
        {
            _bll = bll;
        }

        // ====================== GET BY ID ======================
        [Authorize(Roles = "Admin,ThuNgan,ThuKho,KeToan")]
        [HttpGet("get-by-id/{id}")]
        public IActionResult GetByID(int id)
        {
            var data = _bll.GetDatabyID(id);
            if (data == null)
                return NotFound(new { message = "ReturnID không tồn tại" });
            return Ok(data);
        }

        // ====================== CREATE RETURN ======================
        // Trả hàng khách hoặc trả NCC → ThuNgan + ThuKho + Admin
        [Authorize(Roles = "Admin,ThuNgan,ThuKho")]
        [HttpPost("create")]
        public IActionResult Create([FromBody] ReturnCreateRequest model)
        {
            try
            {
                var newId = _bll.Create(model);
                var createdData = _bll.GetDatabyID(newId);
                return Ok(createdData);
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }

        // ====================== UPDATE RETURN ======================
        [Authorize(Roles = "Admin,ThuNgan,ThuKho")]
        [HttpPost("update")]
        public IActionResult Update([FromBody] ReturnUpdateRequest model)
        {
            try
            {
                var ok = _bll.Update(model);
                if (!ok)
                    return BadRequest(new { error = "Cập nhật không thành công" });

                var updated = _bll.GetDatabyID(model.ReturnID);
                return Ok(updated);
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }

        // ====================== DELETE RETURN ======================
        // Xóa bản ghi → chỉ Admin
        [Authorize(Roles = "Admin")]
        [HttpDelete("delete/{id}")]
        public IActionResult Delete(int id)
        {
            try
            {
                var result = _bll.Delete(id);
                return Ok(new { message = "Xóa thành công", status = result });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }

        // ====================== SEARCH ======================
        // Tìm kiếm: cho phép tất cả vai trò nghiệp vụ
        [Authorize(Roles = "Admin,ThuNgan,ThuKho,KeToan")]
        [HttpPost("search")]
        public IActionResult Search([FromBody] ReturnSearchRequest req)
        {
            try
            {
                long total;
                var data = _bll.Search(
                    req.page,
                    req.pageSize,
                    out total,
                    req.ReturnID,
                    req.ReturnType,
                    req.SaleID,
                    req.ReceiptID,
                    req.CustomerID,
                    req.SupplierID,
                    req.PartnerName,
                    req.PartnerPhone,
                    req.ProductID,
                    req.FromDate,
                    req.ToDate
                );

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
                return BadRequest(new { error = ex.Message });
            }
        }
    }
}
