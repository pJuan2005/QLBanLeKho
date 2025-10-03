using BLL.Interfaces;
using DAL.Interfaces;
using Model;
using System;
using System.Collections.Generic;

namespace BLL
{
    public class ReportBLL : IDReportBLL
    {
        private readonly IDReportDAL _res;

        public ReportBLL(IDReportDAL res)
        {
            _res = res;
        }

        public List<ReportRevenueResponse> GetRevenueReport(DateTime fromDate, DateTime toDate, string option)
        {
            return _res.GetRevenueReport(fromDate, toDate, option);
        }

        public List<ReportImportExportResponse> GetImportExportReport(DateTime fromDate, DateTime toDate)
        {
            return _res.GetImportExportReport(fromDate, toDate);
        }

        public List<ReportStockResponse> GetStockReport()
        {
            return _res.GetStockReport();
        }
    }
}
