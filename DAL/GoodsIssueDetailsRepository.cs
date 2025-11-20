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

        public List<GoodsIssueDetailsModel> GetDatabyID(int issueID)
        {
            string msgError = "";
            try
            {
                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(
                    out msgError,
                    "sp_GoodsIssueDetails_get_by_IssueID",  // tên SP giữ nguyên
                    "@IssueID", issueID);

                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);

                return dt.ConvertTo<GoodsIssueDetailsModel>().ToList();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public bool CreateMultiple(List<GoodsIssueDetailsModel> models)
        {
            string msgError = "";
            try
            {
                // Chuyển danh sách models thành chuỗi JSON
                var jsonData = Newtonsoft.Json.JsonConvert.SerializeObject(models);

                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_GoodsIssueDetails_create_multiple",
                    "@JsonData", jsonData
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
