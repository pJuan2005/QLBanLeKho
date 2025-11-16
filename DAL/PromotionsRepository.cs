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
    public class PromotionsRepository : IPromotionsRepository
    {
        private IDatabaseHelper _dbHelper;

        public PromotionsRepository(IDatabaseHelper dbHelper)
        {
            _dbHelper = dbHelper;
        }

        public PromotionsModel GetDatabyID(int id)
        {
            string msgError = "";
            try
            {
                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msgError, "sp_Promotions_get_by_id",
                    "@PromotionID", id);
                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);
                return dt.ConvertTo<PromotionsModel>().FirstOrDefault();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public bool Create(PromotionsModel model)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_Promotions_create",
                    "@PromotionName", model.PromotionName,
                    "@Type", model.Type,
                    "@Value", model.Value,
                    "@StartDate", model.StartDate,
                    "@EndDate", model.EndDate,
                    "@CategoryID", model.CategoryID
                    );
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

        public bool Update(PromotionsModel model)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_Promotions_update",
                    "@PromotionID", model.PromotionID,
                    "@PromotionName", model.PromotionName,
                    "@Type", model.Type,
                    "@Value", model.Value,
                    "@StartDate", model.StartDate,
                    "@EndDate", model.EndDate,
                    "@CategoryID", model.CategoryID,
                    "Status", model.Status);
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

        public bool Delete(PromotionsModel model)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_Promotions_delete",
                    "@PromotionID", model.PromotionID);
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
        public List<PromotionsModel> Search(int pageIndex, int pageSize, out long total, DateTime? fromDate, DateTime? toDate, string status)
        {
            string msgError = "";
            total = 0;
            try
            {
                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msgError, "sp_Promotions_search",
                    "@page_index", pageIndex,
                    "@page_size", pageSize,
                    "@FromDate", fromDate ?? (object)DBNull.Value,
                    "@ToDate", toDate ?? (object)DBNull.Value,
                    "@Status", string.IsNullOrEmpty(status) ? (object)DBNull.Value : status);


                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);

                if (dt.Rows.Count > 0)
                    total = Convert.ToInt64(dt.Rows[0]["RecordCount"]);

                return dt.ConvertTo<PromotionsModel>().ToList();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }




    }
}
