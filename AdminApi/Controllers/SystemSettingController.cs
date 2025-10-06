using BLL.Interfaces;
using Microsoft.AspNetCore.Mvc;
using Model;
using System;

namespace CoreApi.Controllers
{
    [Route("api/system")]
    [ApiController]
    public class SystemSettingController : ControllerBase
    {
        private readonly IDSystemSettingBLL _systemSettingBLL;

        public SystemSettingController(IDSystemSettingBLL systemSettingBLL)
        {
            _systemSettingBLL = systemSettingBLL;
        }

        [Route("get-by-key/{key}")]
        [HttpGet]
        public SystemSettingModel GetDatabyKey(string key)
        {
            return _systemSettingBLL.GetDatabyKey(key);
        }

        [Route("create")]
        [HttpPost]
        public SystemSettingModel Create([FromBody] SystemSettingModel model)
        {
            _systemSettingBLL.Create(model);
            return model;
        }

        [Route("update")]
        [HttpPost]
        public SystemSettingModel Update([FromBody] SystemSettingModel model)
        {
            _systemSettingBLL.Update(model);
            return model;
        }

        [Route("delete/{id}")]
        [HttpDelete]
        public IActionResult Delete(int id)
        {
            _systemSettingBLL.Delete(id);
            return Ok(new { message = "Xóa cấu hình thành công" });
        }

        [Route("search")]
        [HttpPost]
        public ResponseModel Search([FromBody] SystemSettingSearchRequest request)
        {
            var response = new ResponseModel();
            try
            {
                long total = 0;
                var data = _systemSettingBLL.Search(request.page, request.pageSize, out total,
                    request.SettingKey, request.Description, request.option);
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
