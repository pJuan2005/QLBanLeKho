// File: CoreApi/Controllers/SystemController.cs
using BLL.Interfaces;
using Microsoft.AspNetCore.Mvc;
using Model;
using System;
using System.Collections.Generic;

namespace CoreApi.Controllers
{
    [Route("api/system")]
    [ApiController]
    public class SystemController : ControllerBase
    {
        private readonly ISystemBLL _systemBusiness;

        public SystemController(ISystemBLL systemBusiness)
        {
            _systemBusiness = systemBusiness;
        }


        [HttpPost]
        [Route("settings-create")]
        public SystemSettingModel CreateSetting([FromBody] SystemSettingModel model)
        {
            _systemBusiness.Create(model);
            return model;
        }

        // ✅ THÊM ENDPOINT MỚI ĐỂ XÓA CÀI ĐẶT
        [HttpDelete]
        [Route("settings-delete/{id}")]
        public IActionResult DeleteSetting(int id)
        {
            try
            {
                var result = _systemBusiness.Delete(id);
                if (result)
                {
                    return Ok(new { message = $"Đã xóa thành công cài đặt có ID = {id}" });
                }
                // Trường hợp này ít xảy ra nếu không có lỗi, nhưng để cho chắc chắn
                return NotFound(new { error = $"Không tìm thấy cài đặt có ID = {id}" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }

        [HttpPost]
        [Route("settings-update")]
        public IActionResult UpdateSetting([FromBody] SystemSettingModel model) // Nhận vào một model duy nhất
        {
            try
            {
                var result = _systemBusiness.Update(model);
                if (result)
                {
                    // Trả về chính đối tượng đã được cập nhật
                    return Ok(model);
                }
                return NotFound(); // Hoặc một lỗi khác nếu cần
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }


        [Route("settings-by-id/{id}")]
        [HttpGet]
        public SystemSettingModel GetDatabyID(int id)
        {
            return _systemBusiness.GetDatabyID(id);
        }

        [Route("search-setting")]
        [HttpPost]
        public ResponseModel Search([FromBody] SystemSettingSearchRequest request)
        {
            var response = new ResponseModel();
            try
            {
                long total = 0;
                var data = _systemBusiness.Search(request, out total);

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