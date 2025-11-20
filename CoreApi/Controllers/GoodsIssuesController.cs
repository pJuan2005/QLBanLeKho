using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Model;
using System.Reflection;
using BLL.Interfaces;
using System.Globalization;

namespace CoreApi.Controllers
{
    [Route("api/goodsissues")]
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
        public IActionResult Create([FromBody] GoodsIssuesModel model)
        {
            try
            {
                var issueID = _goodsIssuesBusiness.Create(model);  
                return Ok(new { issueID });  
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
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
                var pageIndex = int.Parse(formData["pageIndex"].ToString());
                var pageSize = int.Parse(formData["pageSize"].ToString());

                // --- FILTERS ---
                decimal? minTotalAmount = null;
                decimal? maxTotalAmount = null;
                int? userId = null;
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

                if (formData.Keys.Contains("userId") &&
                    !string.IsNullOrEmpty(Convert.ToString(formData["userId"])) &&
                    int.TryParse(Convert.ToString(formData["userId"]), out var uid))
                {
                    userId = uid;
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
                var data = _goodsIssuesBusiness.Search(
                    pageIndex, pageSize, out long total,
                    minTotalAmount, maxTotalAmount, userId, fromDate, toDate);

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


    }
}
