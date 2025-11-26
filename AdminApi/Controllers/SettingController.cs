using Microsoft.AspNetCore.Mvc;
using BLL.Interfaces;
using Model;
using Microsoft.AspNetCore.Authorization;

namespace CoreApi.Controllers
{
    [Authorize]
    [Route("api/settings")]
    [ApiController]
    public class SettingsController : ControllerBase
    {
        private readonly IDSettingsBLL _bll;

        public SettingsController(IDSettingsBLL bll)
        {
            _bll = bll;
        }

        // 1️⃣ GET SETTINGS
        [HttpGet("get")]
        public IActionResult Get()
        {
            var data = _bll.GetSettings();
            return Ok(data);
        }

        // 2️⃣ UPDATE SETTINGS
        [HttpPut("update")]
        public IActionResult Update([FromBody] SettingsModel model)
        {
            try
            {
                _bll.UpdateSettings(model);
                return Ok(new { message = "Cập nhật Setting thành công!" });
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        // 3️⃣ GET LANGUAGE LIST
        [HttpGet("languages")]
        public IActionResult GetLanguages()
        {
            return Ok(new[]
            {
                new { Code = "EN", Name = "English" },
                new { Code = "VI", Name = "Tiếng Việt" }
            });
        }
    }
}
