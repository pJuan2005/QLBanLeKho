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
    public partial class GoodsIssuesRepository : IGoodsIssuesRepository
    {
        private IDatabaseHelper _dbHelper;

        public GoodsIssuesRepository(IDatabaseHelper dbHelper)
        {
            _dbHelper = dbHelper;
        }

        public GoodsIssuesModel GetDatabyID(int id)
        {
            string msgError = "";
            try
            {
                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msgError, "sp_GoodsIssues_get_by_id",
                    "@IssueID", id);
                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);
                return dt.ConvertTo<GoodsIssuesModel>().FirstOrDefault();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public bool Create(GoodsIssuesModel model)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_GoodsIssues_create",
                    
                    
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

        public bool Update(GoodsIssuesModel model)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_GoodsIssues_update",
                    "@IssueID", model.IssueID,
                    "@IssueDate", model.IssueDate
                   
                    
                    );

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

        public bool Delete(GoodsIssuesModel model)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_GoodsIssues_delete",
                    "@IssueID", model.IssueID);

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

        public List<GoodsIssuesModel> Search(int pageIndex, int pageSize, out long total, decimal? minTotalAmount, decimal? maxTotalAmount, int? userId, DateTime? fromDate, DateTime? toDate)
        {
            string msgError = "";
            total = 0;
            try
            {
                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msgError, "sp_GoodsIssues_search",
                    "@page_index", pageIndex,
                    "@page_size", pageSize,
                    "@MinTotalAmount", minTotalAmount,
                    "@MaxTotalAmount", maxTotalAmount,
                    "@UserID", userId,
                    "@FromDate", fromDate,
                    "@ToDate", toDate);

                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);

                if (dt.Rows.Count > 0)
                {
                    total = Convert.ToInt64(dt.Rows[0]["RecordCount"]);
                }

                return dt.ConvertTo<GoodsIssuesModel>().ToList();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

    }
}
