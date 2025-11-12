using DAL;
using Helper;
using Microsoft.IdentityModel.Tokens;
using Model;
using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using Microsoft.Extensions.Configuration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BLL.Interfaces;
using DAL.Interfaces;

namespace BLL
{
    public class UserBusiness:IUserBusiness
    {
        private IUserRepository _res;
        private string Secret;
        public UserBusiness(IUserRepository res, IConfiguration configuration)
        {
            Secret = configuration["AppSettings:Secret"];
            _res = res;
        }
        public bool Delete(int id)
        {
            return _res.Delete(id);
        }

        public UserModel Authenticate(string username, string password)
        {
            var user = _res.GetUser(username, password);
            if (user == null)
                return null;

            //authentication successful so generate jwt token
            var tokenHandler = new JwtSecurityTokenHandler(); //tool tạo token
            var key =Encoding.ASCII.GetBytes(Secret);//chuyển secret thành byte
            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(new Claim[]
                {
                    new Claim("UserId",user.UserID.ToString()),
                    new Claim("Username",user.Username),
                    new Claim("FullName",user.FullName??""),
                    new Claim(ClaimTypes.Name, user.FullName.ToString()),
                    new Claim(ClaimTypes.Email,user.Email),
                    new Claim(ClaimTypes.Role,user.Role)
                }),
                Expires = DateTime.UtcNow.AddDays(1),
                SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature)
            };
            var token = tokenHandler.CreateToken(tokenDescriptor);
            user.Token = tokenHandler.WriteToken(token);

            return user;
        }

        public UserModel GetDatabyId(int id)
        {
            return _res.GetDatabyID(id);
        }

        public bool Create(UserModel model)
        {
            return _res.Create(model);
        }

        public bool Update(UserModel model)
        {
            return _res.Update(model);
        }

        public List<UserModel>Search(int pageIndex, int pageSize, out long total, string fullname, string username)
        {
            return _res.Search(pageIndex, pageSize, out total, fullname, username);
        }
    }
}
