using BLL;
using BLL.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Model;
using System;

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
        [Authorize(Roles = "Admin,KeToan,ThuNgan")]
        [Route("revenue")]
        [HttpPost]
        public IActionResult GetRevenueReport([FromBody] ReportRevenueRequest request)
        {
            try
            {
                var from = DateTime.ParseExact(request.FromDate, "yyyy-MM-dd", null);
                var to = DateTime.ParseExact(request.ToDate, "yyyy-MM-dd", null);

                // ❌ KHÔNG cộng thêm 1 ngày nữa
                // to = to.AddDays(1).AddSeconds(-1);

                var data = _reportBusiness.GetRevenueReport(from, to, request.Option);

                return Ok(new { data });
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        // ==================== 2) IMPORT - EXPORT REPORT ====================
        [Authorize(Roles = "Admin,ThuKho,KeToan")]
        [HttpPost("import-export")]
        public IActionResult GetImportExportReport([FromBody] ReportRevenueRequest request)
        {
            try
            {
                var from = DateTime.ParseExact(request.FromDate, "yyyy-MM-dd", null);
                var to = DateTime.ParseExact(request.ToDate, "yyyy-MM-dd", null);

                // ❌ Bỏ đoạn này
                // to = to.AddDays(1).AddSeconds(-1);

                var data = _reportBusiness.GetImportExportReport(from, to, request.Option);

                return Ok(new { data });
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        // ==================== 3) STOCK REPORT ====================
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

        // ==================== 4) TOP PRODUCTS (dashboard donut) ====================
        [Authorize(Roles = "Admin,KeToan,ThuNgan")]
        [HttpPost("top-products")]
        public IActionResult GetTopProducts([FromBody] ReportRevenueRequest request)
        {
            try
            {
                var from = DateTime.ParseExact(request.FromDate, "yyyy-MM-dd", null);
                var to = DateTime.ParseExact(request.ToDate, "yyyy-MM-dd", null);

                var data = _reportBusiness.GetTopProducts(from, to);

                return Ok(new { data });
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }
    }
}
