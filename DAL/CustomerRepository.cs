using DAL.Helper;
using Model;
using System;
using System.Collections.Generic;
using System.Diagnostics.CodeAnalysis;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAL
{
    public class CustomerRepository:ICustomerRepository
    {
        public IDatabaseHelper _dbHelper;
        public CustomerRepository(IDatabaseHelper dbHelper)
        {
            _dbHelper = dbHelper;
        }

        public CustomerModel GetdataById(int id)
        {
            string msgError = "";
            try
            {
                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msgError, "sp_customer_get_by_id",
                    "@CustomerID",id);
                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);
                return dt.ConvertTo<CustomerModel>().FirstOrDefault();

            }catch(Exception ex)
            {
                throw ex;
            }
        }

        public bool Create(CustomerModel model)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_customer_create", "@CustomerName", model.CustomerName,
                    "@Phone",model.Phone,
                    "@Email",model.Email,
                    "@Address",model.Address,
                    "@DebtLimit",model.DebtLimit);
                if ((result != null && !string.IsNullOrEmpty(result.ToString())) || !string.IsNullOrEmpty(msgError))
                    throw new Exception(Convert.ToString(result) + msgError);
                return true;
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }

        public bool Update(CustomerModel model)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_customer_update",
                    "@CustomerID",model.CustomerID,
                    "@CustomerName",model.CustomerName,
                    "@Phone",model.Phone,
                    "@Email",model.Email,
                    "@Address",model.Address,
                    "@DebtLimit",model.DebtLimit);
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
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_customer_delete",
                    "@CustomerID",id);
                if ((result != null && !string.IsNullOrEmpty(result.ToString())) || !string.IsNullOrEmpty(msgError))
                    throw new Exception(Convert.ToString(result) + msgError);
                return true;
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }

        public List<CustomerModel>Search(int pageIndex,int pageSize,out long total, string Phone, string Address)
        {
            string msgError = "";
            total = 0;
            try
            {
                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msgError, "sp_customer_search",
                    "@page_index",pageIndex,
                    "@page_size",pageSize,
                    "@Phone",Phone,
                    "@Address",Address);
                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);
                if (dt.Rows.Count > 0) total = (long)dt.Rows[0]["RecordCount"];
                return dt.ConvertTo<CustomerModel>().ToList();
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }
    }
}
