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

        public GoodsReceiptDetailsModel GetDatabyID(int receiptID)
        {
            string msgError = "";
            try
            {
                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msgError, "sp_GoodsReceiptDetails_get_by_receiptid",
                    "@ReceiptID", receiptID);
                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);
                return dt.ConvertTo<GoodsReceiptDetailsModel>().FirstOrDefault();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public bool Create(GoodsReceiptDetailsModel model)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_GoodsReceiptDetails_create",
                    "@ReceiptID", model.ReceiptID,
                    "@ProductID", model.ProductID,
                    "@Quantity", model.Quantity,
                    "@UnitPrice", model.UnitPrice,
                    
                    "@ExpiryDate", model.ExpiryDate);

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

        public bool Update(GoodsReceiptDetailsModel model)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_GoodsReceiptDetails_update",
                    "@ReceiptID", model.ReceiptID,
                    "@ProductID", model.ProductID,
                    "@Quantity", model.Quantity,
                    "@UnitPrice", model.UnitPrice,
                    
                    "@ExpiryDate", model.ExpiryDate);

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
