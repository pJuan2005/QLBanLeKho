using BLL.Interfaces;
using DAL.Interfaces;
using Microsoft.Extensions.Caching.Memory;
using Model;
using System;
using System.Collections.Generic;

public class ReportBLL : IDReportBLL
{
    private readonly IDReportDAL _res;
    private readonly IMemoryCache _cache;

    public ReportBLL(IDReportDAL res, IMemoryCache cache)
    {
        _res = res;
        _cache = cache;
    }

    // ===================== 1) REVENUE =====================
    public List<ReportRevenueResponse> GetRevenueReport(DateTime fromDate, DateTime toDate, string option)
    {
        string key = $"report_revenue_{fromDate:yyyyMMdd}_{toDate:yyyyMMdd}_{option}";

        if (_cache.TryGetValue(key, out List<ReportRevenueResponse> cached))
            return cached;

        var data = _res.GetRevenueReport(fromDate, toDate, option);

        _cache.Set(key, data,
            new MemoryCacheEntryOptions
            {
                AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(5)
            });

        return data;
    }

    // ===================== 2) IMPORT - EXPORT =====================
    public List<ReportImportExportResponse> GetImportExportReport(DateTime fromDate, DateTime toDate, string option)
    {
        string key = $"report_import_export_{fromDate:yyyyMMdd}_{toDate:yyyyMMdd}_{option}";

        if (_cache.TryGetValue(key, out List<ReportImportExportResponse> cached))
            return cached;

        var data = _res.GetImportExportReport(fromDate, toDate, option);

        _cache.Set(key, data,
            new MemoryCacheEntryOptions
            {
                AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(5)
            });

        return data;
    }

    // ===================== 3) STOCK =====================
    public List<ReportStockResponse> GetStockReport()
    {
        const string key = "report_stock";

        if (_cache.TryGetValue(key, out List<ReportStockResponse> cached))
            return cached;

        var data = _res.GetStockReport();

        _cache.Set(key, data,
            new MemoryCacheEntryOptions
            {
                AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(10)
            });

        public List<ReportStockResponse> GetStockReport()
        {
            return _res.GetStockReport();
        }


        public List<ReportTopProductResponse> GetTopProducts(DateTime fromDate, DateTime toDate)
        {
            return _res.GetTopProducts(fromDate, toDate);
        }

    }
}
