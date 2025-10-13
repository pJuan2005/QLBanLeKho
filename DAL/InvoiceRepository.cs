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
    public class InvoiceRepository : IInvoiceRepository
    {
        private IDatabaseHelper _dbHelper;

        public InvoiceRepository(IDatabaseHelper dbHelper)
        {
            _dbHelper = dbHelper;
        }

        public InvoiceModel GetDatabyID(int id)
        {
            string msgError = "";
            try
            {
                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msgError, "sp_Invoice_get_by_id",
                    "@InvoiceID", id);
                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);
                return dt.ConvertTo<InvoiceModel>().FirstOrDefault();
            }
            catch (Exception ex)
            {
                throw ;
            }
        }

        public bool Create(InvoiceModel model)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_Invoice_create",
                    "@SaleID", model.SaleID);

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

  

        public bool Delete(InvoiceModel model)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_Invoice_delete",
                    "@InvoiceID", model.InvoiceID);

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
    }
}
