using BLL;
using BLL.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Model;
using System;
using System.Collections.Generic;
using Model;

namespace CoreApi.Controllers
{
    [Route("api/report")]
    [ApiController]
    public class ReportController : ControllerBase
    {
        private readonly IDReportBLL _reportBusiness;

        public ReportController(IDReportBLL reportBusiness)
        {
            _reportBusiness = reportBusiness;
        }


        // ==================== 1) REVENUE REPORT ====================
        // Admin, Kế toán, Thu ngân được xem báo cáo doanh thu
        [Authorize(Roles = "Admin,KeToan,ThuNgan")]
        [Route("revenue")]
        [HttpPost]
        public IActionResult GetRevenueReport([FromBody] ReportRevenueRequest request)
        {
            try
            {
                // Chuyển string → DateTime (chống lệch timezone)
                var from = DateTime.ParseExact(request.FromDate, "yyyy-MM-dd", null);
                var to = DateTime.ParseExact(request.ToDate, "yyyy-MM-dd", null);

                // Bao gồm full ngày cuối cùng
                to = to.AddDays(1).AddSeconds(-1);

                var data = _reportBusiness.GetRevenueReport(from, to, request.Option);

                return Ok(new { data });
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }



        [HttpPost("import-export")]
        public IActionResult GetImportExportReport([FromBody] ReportRevenueRequest request)
        // ==================== 2) IMPORT - EXPORT REPORT ====================
        // Admin, Thủ kho, Kế toán được xem báo cáo nhập xuất
        [Authorize(Roles = "Admin,ThuKho,KeToan")]
        [Route("import-export")]
        [HttpGet]
        public IActionResult GetImportExportReport(DateTime fromDate, DateTime toDate)
        {
            try
            {
                // Parse chuẩn
                var from = DateTime.ParseExact(request.FromDate, "yyyy-MM-dd", null);
                var to = DateTime.ParseExact(request.ToDate, "yyyy-MM-dd", null);

                // Bao gồm full ngày cuối
                to = to.AddDays(1).AddSeconds(-1);

                // TRUYỀN from, to CHUẨN XUỐNG BUSINESS
                var data = _reportBusiness.GetImportExportReport(from, to, request.Option);

                return Ok(new { data });
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }



        // ==================== 3) STOCK REPORT ====================
        // Tồn kho: Admin + Thủ kho + Kế toán
        [Authorize(Roles = "Admin,ThuKho,KeToan")]
        [Route("stock")]
        [HttpGet]
        public IActionResult GetStockReport()
        {
            try
            {
                var data = _reportBusiness.GetStockReport();
                return Ok(new { Data = data });
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }
    }
}
