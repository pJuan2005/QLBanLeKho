using DAL.Interfaces;
using DAL.Helper;
using Model;
using System;
using System.Collections.Generic;
using System.Linq;

namespace DAL
{
    public class StockCardDAL : IDStockCardDAL
    {
        private readonly IDatabaseHelper _dbHelper;

        public StockCardDAL(IDatabaseHelper dbHelper)
        {
            _dbHelper = dbHelper;
        }

        public StockCardModel GetDatabyID(int id)
        {
            string msgError = "";
            try
            {
                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msgError, "sp_stockcard_get_by_id",
                     "@StockID", id);
                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);
                return dt.ConvertTo<StockCardModel>().FirstOrDefault();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public bool Create(StockCardModel model)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_stockcard_create",
                    "@ProductID", model.ProductID,
                    "@TransactionType", model.TransactionType,
                    "@Quantity", model.Quantity,
                    "@Balance", model.Balance,
                    "@RefID", model.RefID,
                    "@TransactionDate", model.TransactionDate
                );

                if (!string.IsNullOrEmpty(msgError))
                {
                    throw new Exception(msgError);
                }

                if (result != null && int.TryParse(result.ToString(), out int newId))
                {
                    model.StockID = newId; // Gán StockID mới
                }

                return true;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public bool Update(StockCardModel model)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_stockcard_update",
                    "@StockID", model.StockID,
                    "@ProductID", model.ProductID,
                    "@TransactionType", model.TransactionType,
                    "@Quantity", model.Quantity,
                    "@Balance", model.Balance,
                    "@RefID", model.RefID,
                    "@TransactionDate", model.TransactionDate
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

        public bool Delete(int id)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_stockcard_delete",
                    "@StockID", id
                );

                if (!string.IsNullOrEmpty(msgError))
                {
                    Console.WriteLine("Lỗi: " + msgError);
                    return false;
                }

                Console.WriteLine("Thành công: " + Convert.ToString(result));
                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine("Exception: " + ex.Message);
                return false;
            }
        }

        public List<StockCardModel> Search(int pageIndex, int pageSize, out long total,
                                           int? StockID,
                                           int? ProductID,
                                           string TransactionType,
                                           int? RefID)
        {
            string msgError = "";
            total = 0;
            try
            {
                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msgError, "sp_stockcard_search",
                    "@page_index", pageIndex,
                    "@page_size", pageSize,
                    "@StockID", StockID,
                    "@ProductID", ProductID,
                    "@TransactionType", TransactionType,
                    "@RefID", RefID
                );

                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);

                if (dt.Rows.Count > 0 && dt.Columns.Contains("RecordCount"))
                {
                    total = (long)dt.Rows[0]["RecordCount"];
                }

                return dt.ConvertTo<StockCardModel>().ToList();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
    }
}
