using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using DAL.Helper;
using DAL.Interfaces;
using Model;

namespace DAL
{
    public class PurchaseOrderRepository : IPurchaseOrderRepository
    {
        private IDatabaseHelper _dbHelper;

        public PurchaseOrderRepository(IDatabaseHelper dbHelper)
        {
            _dbHelper = dbHelper;
        }

        public PurchaseOrderModel GetDatabyID(int id)
        {
            string msgError = "";
            try
            {
                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msgError, "sp_PurchaseOrders_get_by_id",
                    "@POID", id);
                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);
                return dt.ConvertTo<PurchaseOrderModel>().FirstOrDefault();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public bool CreateMultiple(List<PurchaseOrderModel> models)
        {
            string msgError = "";
            try
            {
                var jsonData = Newtonsoft.Json.JsonConvert.SerializeObject(models);

                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_PurchaseOrders_create_multiple",
                    "@JsonData", jsonData);

                if ((result != null && !string.IsNullOrEmpty(result.ToString())) || !string.IsNullOrEmpty(msgError))
                {
                    throw new Exception(Convert.ToString(result) + msgError);
                }

                return true;
            }
            catch (Exception ex)
            {
                throw;
            }
        }

        public bool Update(PurchaseOrderModel model)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_PurchaseOrders_update",

                     "@POID", model.POID,
                    "@SupplierID", model.SupplierID,
                    "@OrderDate", model.OrderDate,
                    "@TotalAmount", model.TotalAmount,
                    "@Status", model.Status);
                if ((result != null && !string.IsNullOrEmpty(result.ToString())) || !string.IsNullOrEmpty(msgError))
                {
                    throw new Exception(Convert.ToString(result) + msgError);
                }
                return true;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public bool Delete(PurchaseOrderModel model)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_PurchaseOrders_delete",
                    "@POID", model.POID);
                if ((result != null && !string.IsNullOrEmpty(result.ToString())) || !string.IsNullOrEmpty(msgError))
                {
                    throw new Exception(Convert.ToString(result) + msgError);
                }
                return true;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }


        public List<PurchaseOrderModel> Search(decimal? minTotalAmount, decimal? maxTotalAmount, string status, DateTime? fromDate, DateTime? toDate)
        {
            string msgError = "";
            try
            {
                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msgError, "sp_PurchaseOrders_search",
                    "@MinTotalAmount", minTotalAmount,
                    "@MaxTotalAmount", maxTotalAmount,
                    "@Status", status,
                    "@FromDate", fromDate,
                    "@ToDate", toDate);

                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);

                return dt.ConvertTo<PurchaseOrderModel>().ToList();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
    }
}
