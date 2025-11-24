using System;
using System.Collections.Generic;
using Model;

namespace DAL.Interfaces
{
    public interface IDReportDAL
    {
        List<ReportRevenueResponse> GetRevenueReport(DateTime fromDate, DateTime toDate, string option);
        List<ReportImportExportResponse> GetImportExportReport(DateTime fromDate, DateTime toDate , string option);
        List<ReportStockResponse> GetStockReport();
        List<ReportTopProductResponse> GetTopProducts(DateTime fromDate, DateTime toDate);
    }
}
