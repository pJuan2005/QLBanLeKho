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
    public partial class DonMuaHangRepository : IDonMuaHangRepository
    {
        private IDatabaseHelper _dbHelper;

        public DonMuaHangRepository(IDatabaseHelper dbHelper)
        {
            _dbHelper = dbHelper;
        }

        public DonMuaHangModel GetDatabyID(int id)
        {
            string msgError = "";
            try
            {
                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msgError, "sp_PurchaseOrders_get_by_id",
                    "@POID", id);
                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);
                return dt.ConvertTo<DonMuaHangModel>().FirstOrDefault();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public bool Create(DonMuaHangModel model)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_PurchaseOrders_create",

                    "@SupplierID", model.SupplierID,
                    "@OrderDate", model.OrderDate,
                    "@TotalAmount", model.TotalAmount,
                    "@Status", model.Status);
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
        
        public bool Update(DonMuaHangModel model)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_PurchaseOrders_update",

                     "@POID", model.POID,
                    "@SupplierID", model.SupplierID,
                    "@OrderDate", model.OrderDate,
                    "@TotalAmount", model.TotalAmount,
                    "@Status", model.Status);
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
        public bool Delete(DonMuaHangModel model)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_PurchaseOrders_delete",
                    "@POID", model.POID);
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


        public List<DonMuaHangModel> Search(int pageIndex, int pageSize, out long total, int? SupplierID, DateTime? OrderDate, decimal TotalAmount)
        {
            string msgError = "";
            total = 0;
            try
            {
                // Log hoặc breakpoint để kiểm tra tham số
                Console.WriteLine($"Debug - pageIndex: {pageIndex}, pageSize: {pageSize}");
                Console.WriteLine($"Debug - SupplierID: {SupplierID} (type: {SupplierID?.GetType()})");
                Console.WriteLine($"Debug - OrderDate: {OrderDate} (type: {OrderDate?.GetType()})");
                Console.WriteLine($"Debug - TotalAmount: {TotalAmount}");

                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msgError, "sp_PurchaseOrders_search",
                    "@page_index", pageIndex,
                    "@page_size", pageSize,
                    "@SupplierID", (object)SupplierID ?? DBNull.Value,
                    "@OrderDate", (object)OrderDate ?? DBNull.Value,
                    "@TotalAmount", (object)TotalAmount ?? DBNull.Value);

                // Log kết quả từ stored procedure
                Console.WriteLine($"Debug - msgError: {msgError}");
                Console.WriteLine($"Debug - dt.Rows.Count: {dt?.Rows.Count ?? 0}");
                if (dt?.Rows.Count > 0)
                {
                    Console.WriteLine($"Debug - SobanGhi from first row: {dt.Rows[0]["SobanGhi"]}");
                }

                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);
                if (dt.Rows.Count > 0)
                    total = Convert.ToInt64(dt.Rows[0]["SobanGhi"]);

                return dt.ConvertTo<DonMuaHangModel>().ToList();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Debug - Exception: {ex.Message}");
                throw ex;
            }
        }
    }
}
