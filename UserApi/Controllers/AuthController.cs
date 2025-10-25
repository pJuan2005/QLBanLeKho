using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Model;
using BLL;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using BLL.Interfaces;

namespace UserApi.Controllers
{
    [Route("api/auth")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private IUserBusiness _userBusiness;
        public AuthController(IUserBusiness userBusiness)
        {
            _userBusiness = userBusiness;
        }

        [HttpPost("login")]
        public IActionResult Login([FromBody] AuthenticateModel model)
        {
            var user = _userBusiness.Authenticate(model.Username, model.Password);

            if (user == null)
                return BadRequest(new { message = "Username or password is incorrect!" });
            return Ok(new { userID = user.UserID, fullname = user.FullName, username = user.Username, token = user.Token });
        }

        [HttpPost("register")]
        [AllowAnonymous]
        public IActionResult Register([FromBody] UserModel model)
        {
            if (model == null || string.IsNullOrWhiteSpace(model.Username) || string.IsNullOrWhiteSpace(model.PasswordHash))
                return BadRequest(new { message = "Tên đăng nhập và mật khẩu không được để trống" });
            if (string.IsNullOrWhiteSpace(model.Role)) model.Role = "User";
            var ok = _userBusiness.Create(model);
            if (!ok) return BadRequest(new { message = "Tạo tài khoản thất bại!" });
            var user = _userBusiness.Authenticate(model.Username,model.PasswordHash);

            return Created("", new
            {
                userID = user?.UserID ?? model.UserID,
                username = model.Username,
                fullname = model.FullName,
                role = model.Role,
                token = user?.Token
            });
        }

        [HttpPost("logout")]
        [Authorize]
        public IActionResult Logout()
        {
            return Ok(new { message = "Đã đăng xuất!" });
        }

    }
}
