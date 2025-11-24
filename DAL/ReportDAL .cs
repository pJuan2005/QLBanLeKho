using DAL.Interfaces;
using DAL.Helper;
using Model;
using System;
using System.Collections.Generic;
using System.Linq;

namespace DAL
{
    public class ReportDAL : IDReportDAL
    {
        private readonly IDatabaseHelper _dbHelper;

        public ReportDAL(IDatabaseHelper dbHelper)
        {
            _dbHelper = dbHelper;
        }

        public List<ReportRevenueResponse> GetRevenueReport(DateTime fromDate, DateTime toDate, string option)
        {
            string msgError = "";
            try
            {

                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msgError, "sp_report_revenue",
                    "@FromDate", fromDate,
                    "@ToDate", toDate,
                    "@Option", option);

                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);

                return dt.ConvertTo<ReportRevenueResponse>().ToList();
            }
            catch (Exception ex)
            {
                throw;
            }
        }

        public List<ReportImportExportResponse> GetImportExportReport(
                DateTime fromDate, DateTime toDate, string option)
        {
            string msgError = "";

            var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msgError,
                "sp_report_import_export",
                "@FromDate", fromDate,
                "@ToDate", toDate,
                "@Option", option
            );

            if (!string.IsNullOrEmpty(msgError))
                throw new Exception(msgError);

            return dt.ConvertTo<ReportImportExportResponse>().ToList();
        }


        public List<ReportStockResponse> GetStockReport()
        {
            string msgError = "";
            try
            {
                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msgError, "sp_report_stock");

                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);

                return dt.ConvertTo<ReportStockResponse>().ToList();
            }
            catch (Exception ex)
            {
                throw;
            }
        }
    }
}
