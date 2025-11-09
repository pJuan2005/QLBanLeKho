using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using DAL.Helper;
using DAL.Interfaces;
using Model;
using System.Threading.Tasks;

namespace DAL
{
    public  class PurchaseOrderDetailsRepository : IPurchaseOrderDetailsRepository
    {
        private IDatabaseHelper _dbHelper;

        public PurchaseOrderDetailsRepository(IDatabaseHelper dbHelper)
        {
            _dbHelper = dbHelper;
        }

        public List<PurchaseOrderDetailsModel> GetByPOID(int poid)
        {
            string msgError = "";
            try
            {
                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msgError, "sp_PurchaseOrderDetails_get_by_poid",
                    "@POID", poid);

                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);

                // ÉP KIỂU RÕ RÀNG
                return dt.ConvertTo<PurchaseOrderDetailsModel>().ToList();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }



        public bool CreateMultiple(List<PurchaseOrderDetailsModel> models)
        {
            string msgError = "";
            try
            {
                var jsonData = Newtonsoft.Json.JsonConvert.SerializeObject(models);

                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_PurchaseOrderDetails_create_multiple",
                    "@JsonData", jsonData);

                if ((result != null && !string.IsNullOrEmpty(result.ToString())) || !string.IsNullOrEmpty(msgError))
                {
                    throw new Exception(Convert.ToString(result) + msgError);
                }

                return true;
            }
            catch (Exception ex)
            {
                throw ;
            }
        }



        

        public bool Delete(PurchaseOrderDetailsModel model)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_PurchaseOrderDetails_delete",
                    "@POID", model.POID,
                    "@ProductID", model.ProductID);
                if ((result != null && !string.IsNullOrEmpty(result.ToString())) || !string.IsNullOrEmpty(msgError))
                {
                    throw new Exception(Convert.ToString(result) + msgError);
                }
                return true;
            }
            catch (Exception ex)
            {
                throw ;
            }
        }


    }
}
