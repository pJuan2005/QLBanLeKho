using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Model;
using System.Reflection;
using BLL.Interfaces;
using BLL;


namespace CoreApi.Controllers
{
    [Route("api/GoodsIssueDetails")]
    [ApiController]
    public class GoodsIssueDetailsController : ControllerBase
    {
        private IGoodsIssueDetailsBusiness _goodsIssueDetailsBusiness;

        public GoodsIssueDetailsController(IGoodsIssueDetailsBusiness goodsIssueDetailsBusiness)
        {
            _goodsIssueDetailsBusiness = goodsIssueDetailsBusiness;
        }

        [Route("create")]
        [HttpPost]
        public IActionResult Create([FromBody] List<GoodsIssueDetailsModel> models)
        {
            _goodsIssueDetailsBusiness.CreateMultiple(models);
            return Ok(models);
        }

       

        [Route("delete")]
        [HttpPost]
        public IActionResult Delete([FromBody] GoodsIssueDetailsModel model)
        {
            _goodsIssueDetailsBusiness.Delete(model);
            return Ok(new { data = "OK" });
        }

        
        [Route("get-by-id/{issueID}")]
        [HttpGet]
        public IEnumerable<GoodsIssueDetailsModel> GetDatabyID(int issueID)
        {
            return _goodsIssueDetailsBusiness.GetDatabyID(issueID);
        }


    }
}
