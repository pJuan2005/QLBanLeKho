using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Model;
using System.Reflection;
using BLL.Interfaces;
using BLL;
using Microsoft.AspNetCore.Authorization;


namespace CoreApi.Controllers
{
    [Authorize]
    [Route("api/GoodsIssueDetails")]
    [ApiController]
    public class GoodsIssueDetailsController : ControllerBase
    {
        private IGoodsIssueDetailsBusiness _goodsIssueDetailsBusiness;

        public GoodsIssueDetailsController(IGoodsIssueDetailsBusiness goodsIssueDetailsBusiness)
        {
            _goodsIssueDetailsBusiness = goodsIssueDetailsBusiness;
        }

        [Authorize(Roles = "Admin,ThuKho")]
        [Route("create")]
        [HttpPost]
        public IActionResult Create([FromBody] List<GoodsIssueDetailsModel> models)
        {
            _goodsIssueDetailsBusiness.CreateMultiple(models);
            return Ok(models);
        }

        [Authorize(Roles = "Admin,ThuKho")]

        [Route("delete")]
        [HttpPost]
        public IActionResult Delete([FromBody] GoodsIssueDetailsModel model)
        {
            _goodsIssueDetailsBusiness.Delete(model);
            return Ok(new { data = "OK" });
        }

        [Authorize(Roles = "Admin,ThuKho")]
        [Route("get-by-id/{issueID}")]
        [HttpGet]
        public IEnumerable<GoodsIssueDetailsModel> GetDatabyID(int issueID)
        {
            return _goodsIssueDetailsBusiness.GetDatabyID(issueID);
        }


    }
}
