using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Model;
using System.Reflection;
using BLL.Interfaces;


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
        public GoodsIssueDetailsModel Create([FromBody] GoodsIssueDetailsModel model)
        {
            _goodsIssueDetailsBusiness.Create(model);
            return model;
        }

        [Route("update")]
        [HttpPost]
        public GoodsIssueDetailsModel Update([FromBody] GoodsIssueDetailsModel model)
        {
            _goodsIssueDetailsBusiness.Update(model);
            return model;
        }

        [Route("delete")]
        [HttpPost]
        public IActionResult Delete([FromBody] GoodsIssueDetailsModel model)
        {
            _goodsIssueDetailsBusiness.Delete(model);
            return Ok(new { data = "OK" });
        }

        [Route("get-by-id/{issueID}/{productID}")]
        [HttpGet]
        public GoodsIssueDetailsModel GetDatabyID(int issueID, int productID)
        {
            return _goodsIssueDetailsBusiness.GetDatabyID(issueID, productID);
        }

        
    }
}
