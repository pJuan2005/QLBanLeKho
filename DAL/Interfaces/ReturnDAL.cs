using DAL.Helper;
using Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static System.Runtime.InteropServices.JavaScript.JSType;
using DAL.Interfaces;

namespace DAL
{
    public class ReturnDAL : IDReturnDAL
    {
        private readonly IDatabaseHelper _dbHelper;
        public ReturnDAL(IDatabaseHelper dbHelper)
        {
            _dbHelper = dbHelper;
        }

        public ReturnModel GetDatabyID(int id)
        {
            string msgError = "";
            try
            {
                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msgError, "sp_return_get_by_id",
                     "@ReturnID", id);
                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);
                return dt.ConvertTo<ReturnModel>().FirstOrDefault();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }


        public bool Create(ReturnModel model)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_return_create",
                    "@SaleID", model.SaleID,
                    "@CustomerID", model.CustomerID,
                    "@ReturnDate", model.ReturnDate,
                    "@Reason", model.Reason

                );

                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);

                if (result != null && int.TryParse(result.ToString(), out int newId))
                    model.ReturnID = newId;

                return true;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }




        public bool Update(ReturnModel model)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_return_update",
                    "@ReturnID", model.ReturnID,
                    "@SaleID", model.SaleID,
                    "@CustomerID", model.CustomerID,
                    "@ReturnDate", model.ReturnDate,
                    "@Reason", model.Reason
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



        public bool Delete(int returnId)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_return_delete",
                    "@ReturnID", returnId
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





        public List<ReturnModel> Search(int pageIndex, int pageSize, out long total,
                                         int? ReturnID, int? SaleID, int? CustomerID,
                                         DateTime? FromDate, DateTime? ToDate)
        {
            string msgError = "";
            total = 0;
            try
            {
                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msgError, "sp_return_search",
                    "@page_index", pageIndex,
                    "@page_size", pageSize,
                    "@ReturnID", ReturnID,
                    "@SaleID", SaleID,
                    "@CustomerID", CustomerID,
                    "@FromDate", FromDate,
                    "@ToDate", ToDate
                );
                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);
                if (dt.Rows.Count > 0) total = (long)dt.Rows[0]["RecordCount"];
                return dt.ConvertTo<ReturnModel>().ToList();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
    }
}
