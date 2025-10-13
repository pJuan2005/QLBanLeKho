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
    public partial class GoodsIssueDetailsRepository : IGoodsIssueDetailsRepository
    {
        private IDatabaseHelper _dbHelper;

        public GoodsIssueDetailsRepository(IDatabaseHelper dbHelper)
        {
            _dbHelper = dbHelper;
        }

        public GoodsIssueDetailsModel GetDatabyID(int issueID, int productID)
        {
            string msgError = "";
            try
            {
                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msgError, "sp_GoodsIssueDetails_get_by_id",
                    "@IssueID", issueID,
                    "@ProductID", productID);
                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);
                return dt.ConvertTo<GoodsIssueDetailsModel>().FirstOrDefault();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public bool Create(GoodsIssueDetailsModel model)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_GoodsIssueDetails_create",
                    "@IssueID", model.IssueID,
                    "@ProductID", model.ProductID,
                    "@Quantity", model.Quantity,
                    "@UnitPrice", model.UnitPrice,
                    "@BatchNo", model.BatchNo);

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

        public bool Update(GoodsIssueDetailsModel model)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_GoodsIssueDetails_update",
                    "@IssueID", model.IssueID,
                    "@ProductID", model.ProductID,
                    "@Quantity", model.Quantity,
                    "@UnitPrice", model.UnitPrice,
                    "@BatchNo", model.BatchNo);

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

        public bool Delete(GoodsIssueDetailsModel model)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_GoodsIssueDetails_delete",
                    "@IssueID", model.IssueID,
                    "@ProductID", model.ProductID);

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

       
    }
}
