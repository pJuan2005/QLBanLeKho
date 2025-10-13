using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Model;
using DAL.Helper;
using DAL.Interfaces;

namespace DAL
{
    public class ApSupplierRepository:IApSupplierRepository
    {
        public IDatabaseHelper _dbHelper;
        public ApSupplierRepository(IDatabaseHelper dbHelper)
        {
            _dbHelper = dbHelper;
        }

        public List<ApSupplierModel.ListAp> Search(int pageIndex, int pageSize, out long total, string search)
        {
            string msgError = "";
            total = 0;
            try
            {
                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msgError, "sp_ap_supplier_search",
                    "@page_index",pageIndex,
                    "@page_size",pageSize,
                    "@search",search?? string.Empty);
                if(!string.IsNullOrEmpty(msgError) ) 
                    throw new Exception(msgError);
                if (dt.Rows.Count > 0 && dt.Columns.Contains("RecordCount"))
                    total = Convert.ToInt64(dt.Rows[0]["RecordCount"]);
                return dt.ConvertTo<ApSupplierModel.ListAp>().ToList();
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }

        public ApSupplierModel.DetailAp GetdataById(int id)
        {
            string msgError = "";
            try
            {
                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msgError, "sp_ap_supplier_getdatabyid",
                    "@SupplierID",id);
                if(!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);
                return dt.ConvertTo<ApSupplierModel.DetailAp>().FirstOrDefault();
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }
    }
}
