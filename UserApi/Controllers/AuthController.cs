using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Model;
using BLL;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using BLL.Interfaces;
using AdminApi.Services;
using AdminApi.Services.Interface;
using System.Text.Json;

namespace UserApi.Controllers
{
    [Route("api/auth")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private IUserBusiness _userBusiness;
        private IAuditLogger _auditLogger;
        public AuthController(IUserBusiness userBusiness, IAuditLogger auditLogger)
        {
            _userBusiness = userBusiness;
            _auditLogger = auditLogger;
        }

        [HttpPost("login")]
        public IActionResult Login([FromBody] AuthenticateModel model)
        {
            var user = _userBusiness.Authenticate(model.Username, model.Password);

            if (user == null)
                return BadRequest(new { message = "Username or password is incorrect!" });
            _auditLogger.Log(
                action:$"User {user.Username} logged in",
                entityName:"Users",
                entityId:user.UserID,
                operation: "LOGIN",
                userId:user.UserID,
                username:user.Username,
                fullName:user.FullName,
                details: JsonSerializer.Serialize(new {user.Username, user.Role})
                );
            return Ok(new { userID = user.UserID, fullname = user.FullName, username = user.Username, token = user.Token, role = user.Role, email = user.Email, phone= user.Phone });
        }

        [HttpPost("register")]
        public IActionResult Register([FromBody] UserModel model)
        {
            if (model == null || string.IsNullOrWhiteSpace(model.Username) || string.IsNullOrWhiteSpace(model.PasswordHash))
                return BadRequest(new { message = "Tên đăng nhập và mật khẩu không được để trống!" });

            model.FullName ??= "";
            model.Email ??= "";
            model.Phone ??= "";
            model.Role = string.IsNullOrWhiteSpace(model.Role) ? "User" : model.Role;
            var ok = _userBusiness.Create(model);
            if (!ok)
                return BadRequest(new { message = "Tạo tài khoản thất bại!" });

            _auditLogger.Log(
                action: $"Register new account {model.Username}",
                entityName: "Users",
                entityId: model.UserID,
                operation: "CREATE",
                details: JsonSerializer.Serialize(model)
                );
            return Created("", new
            {
                username = model.Username,
                fullname = model.FullName,
                role = model.Role
            });
        }

        [HttpPost("logout")]
        [Authorize]
        public IActionResult Logout()
        {
            _auditLogger.Log(
                action: "User logged out",
                entityName: "Users",
                entityId: null,
                operation: "LOGOUT",
                details: null
                );
            return Ok(new { message = "Đã đăng xuất!" });
        }

    }
}
