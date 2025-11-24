using System;
using System.Collections.Generic;
using Model;

namespace BLL.Interfaces
{
    public interface IDReportBLL
    {
        List<ReportRevenueResponse> GetRevenueReport(DateTime fromDate, DateTime toDate, string option);
        List<ReportImportExportResponse> GetImportExportReport(DateTime fromDate, DateTime toDate , string option);
        List<ReportStockResponse> GetStockReport();
    }
}
