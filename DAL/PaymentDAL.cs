using DAL.Interfaces;
using DAL.Helper;
using Model;
using System;
using System.Collections.Generic;
using System.Linq;

namespace DAL
{
    public class PaymentDAL : IDPaymentDAL
    {
        private readonly IDatabaseHelper _dbHelper;

        public PaymentDAL(IDatabaseHelper dbHelper)
        {
            _dbHelper = dbHelper;
        }

        public PaymentModel GetByID(int id)
        {
            string msgError = "";
            try
            {
                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msgError, "sp_payment_get_by_id",
                    "@PaymentID", id);
                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);
                return dt.ConvertTo<PaymentModel>().FirstOrDefault();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public bool CreateCustomer(PaymentCustomerModel model)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_payment_create",
                    "@CustomerID", model.CustomerID,
                    "@SaleID", model.SaleID,
                    "@Amount", model.Amount,
                    "@PaymentDate", model.PaymentDate,
                    "@Method", model.Method,
                    "@Description", model.Description
                );

                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);

                if (result != null && int.TryParse(result.ToString(), out int newId))
                    model.PaymentID = newId;

                return true;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public bool CreateSupplier(PaymentSupplierModel model)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_payment_create",
                    "@SupplierID", model.SupplierID,
                    "@ReceiptID", model.ReceiptID,
                    "@Amount", model.Amount,
                    "@PaymentDate", model.PaymentDate,
                    "@Method", model.Method,
                    "@Description", model.Description
                );

                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);

                if (result != null && int.TryParse(result.ToString(), out int newId))
                    model.PaymentID = newId;

                return true;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public bool Update(PaymentModel model)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_payment_update",
                    "@PaymentID", model.PaymentID,
                    "@CustomerID", model.CustomerID,
                    "@SaleID", model.SaleID,
                    "@ReceiptID", model.ReceiptID,
                    "@Amount", model.Amount,
                    "@PaymentDate", model.PaymentDate,
                    "@Method", model.Method,
                    "@Description", model.Description
                );

                if ((result != null && !string.IsNullOrEmpty(result.ToString())) || !string.IsNullOrEmpty(msgError))
                    throw new Exception(Convert.ToString(result) + msgError);

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
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_payment_delete",
                    "@PaymentID", id);

                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);

                return true;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public List<PaymentModel> Search(int pageIndex, int pageSize, out long total,
                                         int? CustomerID,int? SupplierID, int? SaleID,int? ReceiptID, string Method,
                                         DateTime? FromDate, DateTime? ToDate)
        {
            string msgError = "";
            total = 0;
            try
            {
                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msgError, "sp_payment_search",
                    "@page_index", pageIndex,
                    "@page_size", pageSize,
                    "@CustomerID", CustomerID,
                    "@SaleID", SaleID,
                    "@ReceiptID", ReceiptID,
                    "@SupplierID", SupplierID,
                    "@Method", Method,
                    "@FromDate", FromDate,
                    "@ToDate", ToDate
                );

                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);
                if (dt.Rows.Count > 0) total = (long)dt.Rows[0]["RecordCount"];
                return dt.ConvertTo<PaymentModel>().ToList();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
    }
}
