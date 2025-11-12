using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using BLL;
using Model;
using System.Reflection;
using BLL.Interfaces;
using System.Globalization;
using ClosedXML.Excel;

namespace CoreApi.Controllers
{

    [Route("api/purchaseorder")]
    public class PurchaseOrderController : ControllerBase
    {
        private IPurchaseOrderBusiness _purchaseOrderBusiness;
        private IPurchaseOrderDetailsBusiness _purchaseOrderDetailsBusiness;


        public PurchaseOrderController(IPurchaseOrderBusiness donMuaHangBusiness , IPurchaseOrderDetailsBusiness chiTietDonMuaHangBusiness)
        {
            _purchaseOrderBusiness = donMuaHangBusiness;
            _purchaseOrderDetailsBusiness = chiTietDonMuaHangBusiness;
        }

        [Route("create")]
        [HttpPost]
        public IActionResult Create([FromBody] List<PurchaseOrderModel> models)
        {
            _purchaseOrderBusiness.CreateMultiple(models);
            return Ok(models);
        }

        [Route("update")]
        [HttpPost]
        public PurchaseOrderModel Update([FromBody] PurchaseOrderModel model)
        {
            _purchaseOrderBusiness.Update(model);
            return model;
        }

        [Route("delete")]
        [HttpPost]
        public IActionResult Delete([FromBody] PurchaseOrderModel model)
        {
            _purchaseOrderBusiness.Delete(model);
            return Ok(new { data = "OK" });
        }

        [Route("get-by-id/{id}")]
        [HttpGet]
        public PurchaseOrderModel GetDatabyID(int id)
        {
            return _purchaseOrderBusiness.GetDatabyID(id);
        }

        [Route("search")]
        [HttpPost]
        public ResponseModel Search([FromBody] Dictionary<string, object> formData)
        {
            var response = new ResponseModel();
            try
            {
                // --- PAGING ---
                int page = 1, pageSize = 10;
                if (formData != null)
                {
                    if (formData.ContainsKey("page") && int.TryParse(Convert.ToString(formData["page"]), out var p) && p > 0)
                        page = p;
                    if (formData.ContainsKey("pageSize") && int.TryParse(Convert.ToString(formData["pageSize"]), out var ps) && ps > 0)
                        pageSize = ps;
                }

                // --- FILTERS ---
                decimal? minTotalAmount = null, maxTotalAmount = null;
                string status = null;
                DateTime? fromDate = null, toDate = null;

                if (formData != null)
                {
                    if (formData.ContainsKey("minTotalAmount"))
                    {
                        var val = Convert.ToString(formData["minTotalAmount"])?.Trim();
                        if (decimal.TryParse(val, NumberStyles.Any, CultureInfo.InvariantCulture, out var d))
                            minTotalAmount = d;
                    }
                    if (formData.ContainsKey("maxTotalAmount"))
                    {
                        var val = Convert.ToString(formData["maxTotalAmount"])?.Trim();
                        if (decimal.TryParse(val, NumberStyles.Any, CultureInfo.InvariantCulture, out var d))
                            maxTotalAmount = d;
                    }
                    if (formData.ContainsKey("status"))
                        status = Convert.ToString(formData["status"])?.Trim();
                    if (formData.ContainsKey("fromDate"))
                    {
                        var val = Convert.ToString(formData["fromDate"]);
                        if (DateTime.TryParse(val, out var d))
                            fromDate = d;
                    }
                    if (formData.ContainsKey("toDate"))
                    {
                        var val = Convert.ToString(formData["toDate"]);
                        if (DateTime.TryParse(val, out var d))
                            toDate = d;
                    }
                }

                // --- CALL BLL ---
                long total = 0;
                var data = _purchaseOrderBusiness.Search(
                    page, pageSize, out total,
                    minTotalAmount, maxTotalAmount, status, fromDate, toDate);

                response.TotalItems = total;
                response.Data = data;
                response.Page = page;
                response.PageSize = pageSize;
                return response;
            }
            catch (Exception ex)
            {
                // log nếu cần
                throw new Exception(ex.Message);
            }
        }

        [Route("export-excel/{poid}")]
        [HttpGet]
        public IActionResult ExportExcel(int poid)
        {
            try
            {
                // Lấy dữ liệu đơn hàng
                var po = _purchaseOrderBusiness.GetDatabyID(poid);

                if (po == null) return NotFound("Không tìm thấy đơn hàng");

                // Lấy dữ liệu chi tiết đơn hàng
                var details = _purchaseOrderDetailsBusiness.GetByPOID(poid);

                using var workbook = new XLWorkbook();

                // Sheet 1: Thông tin đơn hàng
                var wsPO = workbook.Worksheets.Add("PurchaseOrder");
                wsPO.Cell(1, 1).Value = "POID";
                wsPO.Cell(1, 2).Value = "SupplierID";
                wsPO.Cell(1, 3).Value = "OrderDate";
                wsPO.Cell(1, 4).Value = "TotalAmount";
                wsPO.Cell(1, 5).Value = "Status";

                wsPO.Cell(2, 1).Value = po.POID;
                wsPO.Cell(2, 2).Value = po.SupplierID;
                wsPO.Cell(2, 3).Value = po.OrderDate;
                wsPO.Cell(2, 4).Value = po.TotalAmount;
                wsPO.Cell(2, 5).Value = po.Status;

                wsPO.Columns().AdjustToContents();

                // Sheet 2: Chi tiết đơn hàng
                var wsDetail = workbook.Worksheets.Add("Details");
                wsDetail.Cell(1, 1).Value = "POID";
                wsDetail.Cell(1, 2).Value = "ProductID";
                wsDetail.Cell(1, 3).Value = "NameProduct";
                wsDetail.Cell(1, 4).Value = "Quantity";
                wsDetail.Cell(1, 5).Value = "UnitPrice";

                int row = 2;
                foreach (var d in details)
                {
                    wsDetail.Cell(row, 1).Value = d.POID;
                    wsDetail.Cell(row, 2).Value = d.ProductID;
                    wsDetail.Cell(row, 3).Value = d.NameProduct ?? "";
                    wsDetail.Cell(row, 4).Value = d.Quantity;
                    wsDetail.Cell(row, 5).Value = d.UnitPrice;
                    row++;
                }

                wsDetail.Columns().AdjustToContents();

                // Xuất file
                using var stream = new MemoryStream();
                workbook.SaveAs(stream);
                stream.Position = 0;

                var fileName = $"purchaseorder_{poid}_{DateTime.UtcNow:yyyyMMdd_HHmmss}.xlsx";
                const string contentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";

                return File(stream.ToArray(), contentType, fileName);
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
            }
        }

    }
}
