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
    public partial class GoodsReceiptDetailsRepository : IGoodsReceiptDetailsRepository
    {
        private IDatabaseHelper _dbHelper;

        public GoodsReceiptDetailsRepository(IDatabaseHelper dbHelper)
        {
            _dbHelper = dbHelper;
        }

        public List<GoodsReceiptDetailsModel> GetDatabyID(int receiptID)
        {
            string msgError = "";
            try
            {
                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msgError, "sp_GoodsReceiptDetails_get_by_receiptid",
                    "@ReceiptID", receiptID);
                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);

                return dt.ConvertTo<GoodsReceiptDetailsModel>().ToList();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }



        public bool CreateMultiple(List<GoodsReceiptDetailsModel> models)
        {
            string msgError = "";
            try
            {
                var jsonData = Newtonsoft.Json.JsonConvert.SerializeObject(models);

                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_GoodsReceiptDetails_create_multiple",
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


      
        public bool Delete(GoodsReceiptDetailsModel model)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_GoodsReceiptDetails_delete",
                    "@ReceiptID", model.ReceiptID,
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
