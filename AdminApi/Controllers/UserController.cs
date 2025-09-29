using BLL;
using Model;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using BLL.Interfaces;

namespace AdminApi.Controllers
{
    [Authorize(Roles="Admin")]
    [Route("api/user")]
    [ApiController]
    public class UserController : ControllerBase
    {
        private IUserBusiness _userBusiness;

        public UserController(IUserBusiness userBusiness)
        {
            _userBusiness = userBusiness;
        }

        [Route("create-user")]
        [HttpPost]
        public UserModel Create(UserModel model)
        {
            _userBusiness.Create(model);
            return model;
        }

        [Route("delete-user")]
        [HttpPost]
        public IActionResult DeleteUser([FromBody] int id)
        {
            var ok = _userBusiness.Delete(id);
            if(ok)
            {
                return Ok(new { message = "Đã xoá thành công", id });
            }
            else
            {
                return Ok(new { message = "Xoá không thành công", id });
            }
        }

        [Route("get-by-id/{id}")]
        [HttpGet]
        public UserModel GetDatabyId(int id)
        {
            return _userBusiness.GetDatabyId(id);
        }

        [Route("update-user")]
        [HttpPost]
        public UserModel UpdateUser(UserModel model)
        {
             _userBusiness.Update(model);
            return model;
        }

        [Route("search")]
        [HttpPost]
        public ResponseModel Search([FromBody] Dictionary<string, object> formData)
        {
            var response = new ResponseModel();
            try
            {
                var page = int.Parse(formData["page"].ToString());
                var pageSize = int.Parse(formData["pageSize"].ToString());
                string fullname = "";
                if(formData.Keys.Contains("FullName")&& !string.IsNullOrEmpty(Convert.ToString(formData["FullName"])))
                { fullname = Convert.ToString(formData["FullName"]); }
                string username = "";
                if (formData.Keys.Contains("UserName") && !string.IsNullOrEmpty(Convert.ToString(formData["UserName"]))) 
                { username = Convert.ToString(formData["UserName"]); }
                long total = 0;
                var data = _userBusiness.Search(page, pageSize, out total,fullname, username);
                response.TotalItems = total;
                response.Data = data;
                response.Page = page;
                response.PageSize = pageSize;
                    
            }
            catch(Exception ex)
            {
                throw ex;
            }
            return response;
        }
    }
}
