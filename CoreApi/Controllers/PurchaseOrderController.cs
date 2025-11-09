using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using BLL;
using Model;
using System.Reflection;
using BLL.Interfaces;
using System.Globalization;

namespace CoreApi.Controllers
{

    [Route("api/purchaseorder")]
    public class PurchaseOrderController : ControllerBase
    {
        private IPurchaseOrderBusiness _purchaseOrderBusiness;

        public PurchaseOrderController(IPurchaseOrderBusiness donMuaHangBusiness)
        {
            _purchaseOrderBusiness = donMuaHangBusiness;
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
    }
}
