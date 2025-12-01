using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Model;
using BLL.Interfaces;
using System.Globalization;

namespace CoreApi.Controllers
{
    [Authorize] // bắt buộc phải đăng nhập với mọi endpoint
    [Route("api/goodsissues")]
    [ApiController]
    public class GoodsIssuesController : ControllerBase
    {
        private readonly IGoodsIssuesBusiness _goodsIssuesBusiness;

        public GoodsIssuesController(IGoodsIssuesBusiness goodsIssuesBusiness)
        {
            _goodsIssuesBusiness = goodsIssuesBusiness;
        }

        // ========== CREATE ==========
        [Authorize(Roles = "Admin,ThuKho")]
        [HttpPost("create")]
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

        // ========== UPDATE ==========
        [Authorize(Roles = "Admin,ThuKho")]
        [HttpPost("update")]
        public GoodsIssuesModel Update([FromBody] GoodsIssuesModel model)
        {
            _goodsIssuesBusiness.Update(model);
            return model;
        }

        // ========== DELETE ==========
        [Authorize(Roles = "Admin,ThuKho")]
        [HttpPost("delete")]
        public IActionResult Delete([FromBody] GoodsIssuesModel model)
        {
            _goodsIssuesBusiness.Delete(model);
            return Ok(new { data = "OK" });
        }

        // ========== GET BY ID ==========
        [Authorize(Roles = "Admin,ThuKho,KeToan")]
        [HttpGet("get-by-id/{id}")]
        public GoodsIssuesModel GetDatabyID(int id)
        {
            return _goodsIssuesBusiness.GetDatabyID(id);
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
               
                int? userId = null;
                DateTime? fromDate = null;
                DateTime? toDate = null;

               

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
                     userId, fromDate, toDate);

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
