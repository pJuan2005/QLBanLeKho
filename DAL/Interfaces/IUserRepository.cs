using Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAL.Interfaces
{
    public interface IUserRepository
    {
        UserModel GetUser(string username, string password);
        UserModel GetDatabyID(int id);
        bool Create(UserModel model);
        bool Update(UserModel model);
        bool Delete(int id);
        List<UserModel> Search(int pageIndex, int pageSize, out long total, string fullname, string username);
    }
}
