using Model;
using DAL.Helper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using DAL.Interfaces;

namespace DAL
{
    public class UserRepository:IUserRepository
    {
        private IDatabaseHelper _dbHelper;
        public UserRepository(IDatabaseHelper dbHelper)
        {
            _dbHelper = dbHelper;
        }

        public UserModel GetUser(string username, string password)
        {
            string msgError = "";
            try
            {
                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msgError,
                    "sp_user_get_by_username_password",
                    "@username", username,
                    "@password", password);
                if(!string.IsNullOrEmpty(msgError))
                     throw new Exception(msgError);
                return dt.ConvertTo<UserModel>().FirstOrDefault();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public UserModel GetDatabyID(int id)
        {
            string msgError = "";
            try
            {
                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msgError, "sp_user_get_by_id",
                    "@UserId", id);
                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);
                return dt.ConvertTo<UserModel>().FirstOrDefault();

            }catch(Exception ex)
            {
                throw ex;
            }
        }
        public bool Create(UserModel model)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_user_create",
                    "@Username",model.Username,
                    "@Password",model.Password,
                    "@Role",model.Role,
                    "@FullName",model.FullName,
                    "@Email",model.Email,
                    "@Phone",model.Phone);
                if ((result != null && !string.IsNullOrEmpty(result.ToString())) || !string.IsNullOrEmpty(msgError))
                    throw new Exception(Convert.ToString(result) + msgError);
                return true;
            }catch(Exception ex)
            {
                throw ex;
            }
        }
        public bool Update(UserModel model)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_user_update",
                    "@UserId",model.UserId,
                    "@Username",model.Username,
                    "@Password",model.Password,
                    "@Role",model.Role,
                    "@FullName",model.FullName,
                    "@Email",model.Email,
                    "@Phone",model.Phone);
                if ((result != null && !string.IsNullOrEmpty(result.ToString())) || !string.IsNullOrEmpty(msgError))
                    throw new Exception(Convert.ToString(result) + msgError);
                return true;
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }
        public bool Delete(int id)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_user_delete",
                    "@UserId", id);
                if ((result != null && !string.IsNullOrEmpty(result.ToString())) || !string.IsNullOrEmpty(msgError))
                    throw new Exception(Convert.ToString(result) + msgError);
                return true;
            }catch(Exception ex)
            {
                throw ex;
            }
        }
        public List<UserModel>Search(int pageIndex, int pageSize, out long total,string fullname,string username)
        {
            string msgError = "";
            total = 0;
            try
            {
                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msgError, "sp_user_search",
                    "@pageIndex", pageIndex,
                    "@pageSize", pageSize,
                    "@total", total,
                    "@fullName", fullname,
                    "@username", username);
                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);
                if(dt.Rows.Count > 0)
                    total = (long)dt.Rows[0]["RecordCount"];
                return dt.ConvertTo<UserModel>().ToList();
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }
    }
}
