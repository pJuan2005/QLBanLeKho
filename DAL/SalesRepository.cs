using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Model;
using DAL.Interfaces;
using DAL.Helper;


namespace DAL
{
    public class SalesRepository : ISalesRepository
    {
        private IDatabaseHelper _dbHelper;

        public SalesRepository(IDatabaseHelper dbHelper)
        {
            _dbHelper = dbHelper;
        }

        public SalesModel GetDatabyID(int id)
        {
            string msgError = "";
            try
            {
                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msgError, "sp_Sales_get_by_id",
                    "@SaleID", id);
                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);
                return dt.ConvertTo<SalesModel>().FirstOrDefault();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

            public bool Create(SalesModel model)
            {
                string msgError = "";
                try
                {
                    var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_Sales_create",
                        "@CustomerID", model.CustomerID,
                        "@UserID", model.UserID
                        
                        );
                    

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


        public bool Update(SalesModel model)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_Sales_update",
                    "@SaleID", model.SaleID,
                    "@CustomerID", model.CustomerID,
                    "@UserID", model.UserID,
                    "@SaleDate", model.SaleDate,
                    "@PaymentStatus", model.PaymentStatus,
                    "@TotalAmount", model.TotalAmount,
                    "@VATAmount", model.VATAmount);

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

        public bool Delete(SalesModel model)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_Sales_delete",
                    "@SaleID", model.SaleID);

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

        public List<SalesModel> Search(int pageIndex, int pageSize, out long total, decimal? minTotalAmount, decimal? maxTotalAmount, string status, DateTime? fromDate, DateTime? toDate)
        {
            string msgError = "";
            total = 0;
            try
            {
                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msgError, "sp_Sales_search",
                    "@page_index", pageIndex,
                    "@page_size", pageSize,
                    "@MinTotalAmount", minTotalAmount,
                    "@MaxTotalAmount", maxTotalAmount,
                    "@Status", status,
                    "@FromDate", fromDate,
                    "@ToDate", toDate);

                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);

                if (dt.Rows.Count > 0)
                {
                    total = Convert.ToInt64(dt.Rows[0]["RecordCount"]);
                }

                return dt.ConvertTo<SalesModel>().ToList();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

    }
}
