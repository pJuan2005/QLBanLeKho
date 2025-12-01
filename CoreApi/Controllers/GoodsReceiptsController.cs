using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Model;
using BLL.Interfaces;
using System.Globalization;
using ClosedXML.Excel;

namespace CoreApi.Controllers
{
    [Authorize] // bắt buộc phải đăng nhập với mọi endpoint
    [Route("api/goodsreceipts")]
    [ApiController]
    public class GoodsReceiptsController : ControllerBase
    {
        private readonly IGoodsReceiptsBusiness _goodsReceiptsBusiness;
        private readonly IGoodsReceiptDetailsBusiness _goodsReceiptDetailsBusiness;

        public GoodsReceiptsController(
            IGoodsReceiptsBusiness goodsReceiptsBusiness,
            IGoodsReceiptDetailsBusiness goodsReceiptDetailsBusiness)
        {
            _goodsReceiptsBusiness = goodsReceiptsBusiness;
            _goodsReceiptDetailsBusiness = goodsReceiptDetailsBusiness;
        }

        // ========== CREATE ==========
        [Authorize(Roles = "Admin,ThuKho")]
        [HttpPost("create")]
        public IActionResult Create([FromBody] GoodsReceiptsModel model)
        {
            var receiptID = _goodsReceiptsBusiness.Create(model);
            return Ok(new { ReceiptID = receiptID });
        }

        // ========== UPDATE ==========
        [Authorize(Roles = "Admin,ThuKho")]
        [HttpPost("update")]
        public GoodsReceiptsModel Update([FromBody] GoodsReceiptsModel model)
        {
            _goodsReceiptsBusiness.Update(model);
            return model;
        }

        // ========== DELETE ==========
        [Authorize(Roles = "Admin,ThuKho")]
        [HttpPost("delete")]
        public IActionResult Delete([FromBody] GoodsReceiptsModel model)
        {
            _goodsReceiptsBusiness.Delete(model);
            return Ok(new { data = "OK" });
        }

        // ========== GET BY ID ==========
        [Authorize(Roles = "Admin,ThuKho,KeToan")]
        [HttpGet("get-by-id/{id}")]
        public GoodsReceiptsModel GetDatabyID(int id)
        {
            return _goodsReceiptsBusiness.GetDatabyID(id);
        }

        // ========== SEARCH ==========
        [Authorize(Roles = "Admin,ThuKho,KeToan")]
        [HttpPost("search")]
        public ResponseModel Search([FromBody] Dictionary<string, object> formData)
        {
            var response = new ResponseModel();
            try
            {
                // --- PAGING ---
                var pageIndex = int.Parse(formData["pageIndex"].ToString());
                var pageSize = int.Parse(formData["pageSize"].ToString());

                // --- FILTERS ---
                decimal? minTotalAmount = null;
                decimal? maxTotalAmount = null;
                int? poid = null;
                DateTime? fromDate = null;
                DateTime? toDate = null;

                if (formData.Keys.Contains("minTotalAmount") &&
                    !string.IsNullOrEmpty(Convert.ToString(formData["minTotalAmount"])) &&
                    decimal.TryParse(Convert.ToString(formData["minTotalAmount"]), out var minAmt))
                {
                    minTotalAmount = minAmt;
                }

                if (formData.Keys.Contains("maxTotalAmount") &&
                    !string.IsNullOrEmpty(Convert.ToString(formData["maxTotalAmount"])) &&
                    decimal.TryParse(Convert.ToString(formData["maxTotalAmount"]), out var maxAmt))
                {
                    maxTotalAmount = maxAmt;
                }

                if ((formData.Keys.Contains("POID") || formData.Keys.Contains("poid")) &&
                    int.TryParse(Convert.ToString(formData.ContainsKey("POID") ? formData["POID"] : formData["poid"]), out var pid))
                {
                    poid = pid;
                }

                if (formData.Keys.Contains("fromDate") &&
                    DateTime.TryParse(Convert.ToString(formData["fromDate"]), out var fd))
                {
                    fromDate = fd;
                }

                if (formData.Keys.Contains("toDate") &&
                    DateTime.TryParse(Convert.ToString(formData["toDate"]), out var td))
                {
                    toDate = td;
                }

                // --- CALL BLL ---
                var data = _goodsReceiptsBusiness.Search(
                    pageIndex, pageSize, out long total,
                    minTotalAmount, maxTotalAmount, poid, fromDate, toDate);

                response.TotalItems = total;
                response.Data = data;
                response.Page = pageIndex;
                response.PageSize = pageSize;
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return response;
        }

        // ========== EXPORT EXCEL ==========
        [Authorize(Roles = "Admin,ThuKho,KeToan")]
        [HttpGet("export-excel/{receiptID}")]
        public IActionResult ExportGoodsReceiptExcel(int receiptID)
        {
            try
            {
                // Lấy dữ liệu phiếu nhập
                var receipt = _goodsReceiptsBusiness.GetDatabyID(receiptID);
                if (receipt == null)
                    return NotFound("Không tìm thấy phiếu nhập");

                // Lấy dữ liệu chi tiết phiếu nhập
                var details = _goodsReceiptDetailsBusiness.GetDatabyID(receiptID);

                using var workbook = new XLWorkbook();

                // Sheet 1: Thông tin phiếu nhập
                var wsReceipt = workbook.Worksheets.Add("GoodsReceipt");
                wsReceipt.Cell(1, 1).Value = "ReceiptID";
                wsReceipt.Cell(1, 2).Value = "POID";
                wsReceipt.Cell(1, 3).Value = "ReceiptDate";
                wsReceipt.Cell(1, 4).Value = "TotalAmount";
                wsReceipt.Cell(1, 5).Value = "UserID";
                wsReceipt.Cell(1, 6).Value = "BatchNo";
                wsReceipt.Cell(1, 7).Value = "Status";

                wsReceipt.Cell(2, 1).Value = receipt.ReceiptID;
                wsReceipt.Cell(2, 2).Value = receipt.POID;
                wsReceipt.Cell(2, 3).Value = receipt.ReceiptDate;
                wsReceipt.Cell(2, 4).Value = receipt.TotalAmount;
                wsReceipt.Cell(2, 5).Value = receipt.UserID;
                wsReceipt.Cell(2, 6).Value = receipt.BatchNo ?? "";
                wsReceipt.Cell(2, 7).Value = receipt.Status ?? "";

                wsReceipt.Columns().AdjustToContents();

                // Sheet 2: Chi tiết phiếu nhập
                var wsDetail = workbook.Worksheets.Add("Details");
                wsDetail.Cell(1, 1).Value = "ReceiptID";
                wsDetail.Cell(1, 2).Value = "ProductID";
                wsDetail.Cell(1, 3).Value = "ProductName";
                wsDetail.Cell(1, 4).Value = "Quantity";
                wsDetail.Cell(1, 5).Value = "UnitPrice";
                wsDetail.Cell(1, 6).Value = "ExpiryDate";

                int row = 2;
                foreach (var d in details)
                {
                    wsDetail.Cell(row, 1).Value = d.ReceiptID;
                    wsDetail.Cell(row, 2).Value = d.ProductID;
                    wsDetail.Cell(row, 3).Value = d.ProductName ?? "";
                    wsDetail.Cell(row, 4).Value = d.Quantity;
                    wsDetail.Cell(row, 5).Value = d.UnitPrice;
                    wsDetail.Cell(row, 6).Value = d.ExpiryDate?.ToString("yyyy-MM-dd") ?? "";
                    row++;
                }

                wsDetail.Columns().AdjustToContents();

                using var stream = new MemoryStream();
                workbook.SaveAs(stream);
                stream.Position = 0;

                var fileName = $"goodsreceipt_{receiptID}_{DateTime.UtcNow:yyyyMMdd_HHmmss}.xlsx";
                const string contentType =
                    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";

                return File(stream.ToArray(), contentType, fileName);
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }
    }
}
