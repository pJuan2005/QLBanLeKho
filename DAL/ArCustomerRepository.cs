using System;
using Model;
using DAL.Helper;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using DAL.Interfaces;

namespace DAL
{
    public class ArCustomerRepository:IArCustomerRepository
    {
        public IDatabaseHelper _dbHelper;
        public ArCustomerRepository(IDatabaseHelper dbHelper)
        {
            _dbHelper = dbHelper;
        }

        public List<ArCustomerModel.ListAr>Search(int pageIndex, int pageSize,out long total, string search)
        {
            string msgError = "";
            total = 0;
            try
            {
                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msgError, "sp_ar_customer_search",
                    "@page_index", pageIndex, "@page_size", pageSize, "@search", search ?? string.Empty);
                if(!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);
                if (dt.Rows.Count > 0 && dt.Columns.Contains("RecordCount"))
                    total = Convert.ToInt64(dt.Rows[0]["RecordCount"]);
                return dt.ConvertTo<ArCustomerModel.ListAr>().ToList();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public ArCustomerModel.DetailAr GetDetail(int id)
        {
            string msgError = "";
            try
            {
                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msgError, "sp_ar_customer_detail",
                    "@CustomerID",id);
                if(!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);
                return dt.ConvertTo<ArCustomerModel.DetailAr>().FirstOrDefault();
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }

        public decimal GetDebtLimit(int id)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_ar_get_debt_limit",
                    "@CustomerID", id);
                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);
                return result == null ? 0m : Convert.ToDecimal(result);
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }

        public decimal GetCurrentDebt(int id)
        {
            string msgError = "";
            var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_ar_get_current_debt",
                "@CustomerID", id);
            if (!string.IsNullOrEmpty(msgError))
                throw new Exception(msgError);
            return result == null ? 0m : Convert.ToDecimal(result);
        }
    }
}
