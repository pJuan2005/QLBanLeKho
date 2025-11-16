using BLL.Interfaces;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Model;

namespace CoreApi.Controllers {
[Route("api/return")]
[ApiController]
public class ReturnController : ControllerBase
{
    private readonly IReturnBLL _bll;
    public ReturnController(IReturnBLL bll)
    {
        _bll = bll;
    }


    [HttpGet("get-by-id/{id}")]
    public IActionResult GetByID(int id)
    {
        var data = _bll.GetDatabyID(id);
        if (data == null)
            return NotFound(new { message = "ReturnID không tồn tại" });
        return Ok(data);
    }


        [HttpPost("create")]
        public IActionResult Create([FromBody] ReturnCreateRequest model)
        {
            try
            {
                // Tạo mới và lấy ReturnID
                var newId = _bll.Create(model);

                // Lấy lại bản ghi vừa tạo
                var createdData = _bll.GetDatabyID(newId);

                return Ok(createdData);
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }




        [HttpPost("update")]
        public IActionResult Update([FromBody] ReturnUpdateRequest model)
        {
            try
            {
                var updateSuccess = _bll.Update(model);

                if (!updateSuccess)
                    return BadRequest(new { error = "Cập nhật không thành công" });

                // Lấy lại dữ liệu đã cập nhật
                var updatedData = _bll.GetDatabyID(model.ReturnID);

                return Ok(updatedData);
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }



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
