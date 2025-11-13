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
    public partial class GoodsReceiptsRepository : IGoodsReceiptsRepository
    {
        private IDatabaseHelper _dbHelper;

        public GoodsReceiptsRepository(IDatabaseHelper dbHelper)
        {
            _dbHelper = dbHelper;
        }

        public GoodsReceiptsModel GetDatabyID(int id)
        {
            string msgError = "";
            try
            {
                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msgError, "sp_GoodsReceipts_get_by_id",
                    "@ReceiptID", id);
                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);
                return dt.ConvertTo<GoodsReceiptsModel>().FirstOrDefault();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public bool CreateMultiple(List<GoodsReceiptsModel> models)
        {
            string msgError = "";
            try
            {
                var jsonData = Newtonsoft.Json.JsonConvert.SerializeObject(models);

                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_GoodsReceipts_create_multiple",
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


        public bool Update(GoodsReceiptsModel model)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_GoodsReceipts_update",
                    "@ReceiptID", model.ReceiptID,
                    "@POID", model.POID,
                    "@ReceiptDate", model.ReceiptDate,
                    "@TotalAmount", model.TotalAmount,
                    "@UserID", model.UserID);

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

        public bool Delete(GoodsReceiptsModel model)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_GoodsReceipts_delete",
                    "@ReceiptID", model.ReceiptID);

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

        public List<GoodsReceiptsModel> Search(int pageIndex, int pageSize, out long total, decimal? minTotalAmount, decimal? maxTotalAmount, int? poid, DateTime? fromDate, DateTime? toDate)
        {
            string msgError = "";
            total = 0;
            try
            {
                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msgError, "sp_GoodsReceipts_search",
                    "@page_index", pageIndex,
                    "@page_size", pageSize,
                    "@MinTotalAmount", minTotalAmount,
                    "@MaxTotalAmount", maxTotalAmount,
                    "@POID", poid,
                    "@FromDate", fromDate,
                    "@ToDate", toDate);

                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);

                if (dt.Rows.Count > 0)
                {
                    total = Convert.ToInt64(dt.Rows[0]["RecordCount"]);
                }

                return dt.ConvertTo<GoodsReceiptsModel>().ToList();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

    }
}
