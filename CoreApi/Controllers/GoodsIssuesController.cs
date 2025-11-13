using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Model;
using System.Reflection;
using BLL.Interfaces;
using System.Globalization;

namespace CoreApi.Controllers
{
    [Route("api/GoodsIssues")]
    [ApiController]
    public class GoodsIssuesController : ControllerBase
    {
        private IGoodsIssuesBusiness _goodsIssuesBusiness;

        public GoodsIssuesController(IGoodsIssuesBusiness goodsIssuesBusiness)
        {
            _goodsIssuesBusiness = goodsIssuesBusiness;
        }

        [Route("create")]
        [HttpPost]
        public GoodsIssuesModel Create([FromBody] GoodsIssuesModel model)
        {
            _goodsIssuesBusiness.Create(model);
            return model;
        }

        [Route("update")]
        [HttpPost]
        public GoodsIssuesModel Update([FromBody] GoodsIssuesModel model)
        {
            _goodsIssuesBusiness.Update(model);
            return model;
        }

        [Route("delete")]
        [HttpPost]
        public IActionResult Delete([FromBody] GoodsIssuesModel model)
        {
            _goodsIssuesBusiness.Delete(model);
            return Ok(new { data = "OK" });
        }

        [Route("get-by-id/{id}")]
        [HttpGet]
        public GoodsIssuesModel GetDatabyID(int id)
        {
            return _goodsIssuesBusiness.GetDatabyID(id);
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
                int? userId = null;
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

                    if (formData.ContainsKey("userId"))
                    {
                        var val = Convert.ToString(formData["userId"])?.Trim();
                        if (int.TryParse(val, out var uid))
                            userId = uid;
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
                var data = _goodsIssuesBusiness.Search(
                    page, pageSize, out total,
                    minTotalAmount, maxTotalAmount, userId, fromDate, toDate);

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
