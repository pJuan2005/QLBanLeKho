using DAL.Helper;
using DAL.Interfaces;
using Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAL
{
    public class SupplierRepository:ISupplierRepository
    {
        private IDatabaseHelper _dbHelper;
        public SupplierRepository(IDatabaseHelper dbHelper)
        {
            _dbHelper = dbHelper;
        }

        public SupplierModel GetdataByID(int id)
        {
            string msgError = "";
            try
            {
                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msgError, "sp_supplier_get_by_id", "@SupplierID", id);
                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);
                return dt.ConvertTo<SupplierModel>().FirstOrDefault();
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }

        public bool Create(SupplierModel model)
        {
            string msgError = "";
            try
            {
                var resulst = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_supplier_create",
                     "@SupplierName", model.SupplierName,
                    "@Address",model.Address, "@Phone",model.Phone, "@Email",model.Email);
                if ((resulst != null && !string.IsNullOrEmpty(resulst.ToString())) || !string.IsNullOrEmpty(msgError))
                    throw new Exception(Convert.ToString(resulst) + msgError);
                return true;
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }

        public bool Update(SupplierModel model)
        {
            var msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_supplier_update", "@SupplierID", model.SupplierID,
                    "@SupplierName", model.SupplierName, "@Address", model.Address, "@Phone", model.Phone, "@Email", model.Email);
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
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_supplier_delete", "@SupplierID", id);
                if ((result != null && !string.IsNullOrEmpty(result.ToString())) || !string.IsNullOrEmpty(msgError))
                    throw new Exception(Convert.ToString(result));
                return true;
            }catch(Exception ex)
            {
                throw ex;
            }
        }

        public List<SupplierModel>Search(int pageIndex, int pageSize, out long total, string Phone)
        {
            string msgError = "";
            total = 0;
            try
            {
                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msgError, "sp_supplier_search", "@page_index", pageIndex,
                    "@page_size", pageSize, "@Phone", Phone);
                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);
                if (dt.Rows.Count > 0)
                    total = (long)dt.Rows[0]["RecordCount"];
                return dt.ConvertTo<SupplierModel>().ToList();
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }
    }
}
