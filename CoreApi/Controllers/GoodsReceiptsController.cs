using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Model;
using System.Reflection;
using BLL.Interfaces;
using BLL;
using System.Globalization;

namespace CoreApi.Controllers
{
    [Route("api/GoodsReceipts")]
    [ApiController]
    public class GoodsReceiptsController : ControllerBase
    {
        private IGoodsReceiptsBusiness _goodsReceiptsBusiness;

        public GoodsReceiptsController(IGoodsReceiptsBusiness goodsReceiptsBusiness)
        {
            _goodsReceiptsBusiness = goodsReceiptsBusiness;
        }

        [Route("create")]
        [HttpPost]
        public IActionResult Create([FromBody] List<GoodsReceiptsModel> models)
        {
            _goodsReceiptsBusiness.CreateMultiple(models);
            return Ok(models);
        }


        [Route("update")]
        [HttpPost]
        public GoodsReceiptsModel Update([FromBody] GoodsReceiptsModel model)
        {
            _goodsReceiptsBusiness.Update(model);
            return model;
        }

        [Route("delete")]
        [HttpPost]
        public IActionResult Delete([FromBody] GoodsReceiptsModel model)
        {
            _goodsReceiptsBusiness.Delete(model);
            return Ok(new { data = "OK" });
        }

        [Route("get-by-id/{id}")]
        [HttpGet]
        public GoodsReceiptsModel GetDatabyID(int id)
        {
            return _goodsReceiptsBusiness.GetDatabyID(id);
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
                int? poid = null;
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

                    if (formData.ContainsKey("poid"))
                    {
                        var val = Convert.ToString(formData["poid"])?.Trim();
                        if (int.TryParse(val, out var pid))
                            poid = pid;
                    }

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
                var data = _goodsReceiptsBusiness.Search(
                    page, pageSize, out total,
                    minTotalAmount, maxTotalAmount, poid, fromDate, toDate);

                response.TotalItems = total;
                response.Data = data;
                response.Page = page;
                response.PageSize = pageSize;
                return response;
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
        }

    }
}
