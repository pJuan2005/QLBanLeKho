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
    public class SalesItemRepository : ISalesItemRepository
    {
        private IDatabaseHelper _dbHelper;

        public SalesItemRepository(IDatabaseHelper dbHelper)
        {
            _dbHelper = dbHelper;
        }

        public SalesItemModel GetDatabyID(int saleID, int productID)
        {
            string msgError = "";
            try
            {
                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msgError, "sp_SalesItem_get_by_id",
                    "@SaleID", saleID,
                    "@ProductID", productID);

                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);

                return dt.ConvertTo<SalesItemModel>().FirstOrDefault();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public bool Create(SalesItemModel model)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_SalesItem_create",
                    "@SaleID", model.SaleID,
                    "@ProductID", model.ProductID,
                    "@Quantity", model.Quantity);

                if ((result != null && !string.IsNullOrEmpty(result.ToString())) || !string.IsNullOrEmpty(msgError))
                    throw new Exception(Convert.ToString(result) + msgError);

                return true;
            }
            catch (Exception ex)
            {
                throw ;
            }
        }

        public bool Update(SalesItemModel model)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_SalesItem_update",
                    "@SaleID", model.SaleID,
                    "@ProductID", model.ProductID,
                    "ProductName", model.ProductName,
                    "@Quantity", model.Quantity,
                    "@UnitPrice", model.UnitPrice,
                    "@Discount", model.Discount);

                if ((result != null && !string.IsNullOrEmpty(result.ToString())) || !string.IsNullOrEmpty(msgError))
                    throw new Exception(Convert.ToString(result) + msgError);

                return true;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public bool Delete(SalesItemModel model)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_SalesItem_delete",
                    "@SaleID", model.SaleID,
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
