using BLL;
using BLL.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Model;
using System;
using System.Collections.Generic;

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
                var data = _reportBusiness.GetRevenueReport(
                    request.FromDate,
                    request.ToDate,
                    request.Option
                );

                return Ok(new { Data = data });
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        // ==================== 2) IMPORT - EXPORT REPORT ====================
        // Admin, Thủ kho, Kế toán được xem báo cáo nhập xuất
        [Authorize(Roles = "Admin,ThuKho,KeToan")]
        [Route("import-export")]
        [HttpGet]
        public IActionResult GetImportExportReport(DateTime fromDate, DateTime toDate)
        {
            try
            {
                var data = _reportBusiness.GetImportExportReport(fromDate, toDate);
                return Ok(new { Data = data });
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
