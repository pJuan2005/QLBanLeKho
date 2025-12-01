using DAL.Helper;
using DAL.Interfaces;
using Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using static System.Runtime.InteropServices.JavaScript.JSType;

namespace DAL
{
    public class ReturnDAL : IReturnDAL
    {
        private readonly IDatabaseHelper _dbHelper;
        public ReturnDAL(IDatabaseHelper dbHelper)
        {
            _dbHelper = dbHelper;
        }


        public ReturnModel GetDatabyID(int id)
        {
            string msg = "";
            var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msg,
            "sp_return_get_by_id",
            "@ReturnID", id);


            if (!string.IsNullOrEmpty(msg)) throw new Exception(msg);
            return dt.ConvertTo<ReturnModel>().FirstOrDefault();
        }


        public int Create(ReturnCreateRequest model)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction2(
                    out msgError, "sp_return_create",
                    "@ReturnType", model.ReturnType,
                    "@SaleID", model.SaleID,
                    "@POID", model.POID,
                    "@ProductID", model.ProductID,
                    "@Quantity", model.Quantity,
                    "@ReturnDate", model.ReturnDate,
                    "@Reason", model.Reason
                );

                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);

                return Convert.ToInt32(result);
            }
            catch (Exception ex)
            {
                throw;  // không cần throw ex
            }
        }




        public bool Update(ReturnUpdateRequest model)
        {
            string msgError = "";

            var result = _dbHelper.ExecuteScalarSProcedureWithTransaction2(
                out msgError, "sp_return_update",
                "@ReturnID", model.ReturnID,
                "@ReturnType", model.ReturnType,
                "@SaleID", model.SaleID,
                "@POID", model.POID,
                "@ProductID", model.ProductID,
                "@Quantity", model.Quantity,
                "@ReturnDate", model.ReturnDate,
                "@Reason", model.Reason
            );

            // ❗ Nếu SQL RAISERROR thì msgError có giá trị
            if (!string.IsNullOrEmpty(msgError))
            {
                // trả false cho Controller
                throw new Exception(msgError);
            }

            return true;
        }



        public bool Delete(int id)
        {
            string msg = "";
            _dbHelper.ExecuteScalarSProcedureWithTransaction(out msg,
            "sp_return_delete",
            "@ReturnID", id);


            if (!string.IsNullOrEmpty(msg)) throw new Exception(msg);
            return true;
        }



        public List<ReturnModel> Search(int pageIndex, int pageSize, out long total,
                                            int? ReturnID, byte? ReturnType,
                                            int? SaleID, int? POID,
                                            int? CustomerID, int? SupplierID,
                                            string? PartnerName, string? PartnerPhone,
                                            int? ProductID,
                                            DateTime? FromDate, DateTime? ToDate)
                                                    {
            string msg = "";
            total = 0;


            var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msg,
            "sp_return_search",
            "@page_index", pageIndex,
            "@page_size", pageSize,
            "@ReturnID", ReturnID,
            "@ReturnType", ReturnType,
            "@SaleID", SaleID,
            "@POID", POID,
            "@CustomerID", CustomerID,
            "@SupplierID", SupplierID,
            "@PartnerName", PartnerName,
            "@PartnerPhone", PartnerPhone,
            "@ProductID", ProductID,
            "@FromDate", FromDate,
            "@ToDate", ToDate
            );


            if (!string.IsNullOrEmpty(msg)) throw new Exception(msg);
            if (dt.Rows.Count > 0)
                total = Convert.ToInt64(dt.Rows[0]["RecordCount"]);



            return dt.ConvertTo<ReturnModel>().ToList();
        }

    }
}
