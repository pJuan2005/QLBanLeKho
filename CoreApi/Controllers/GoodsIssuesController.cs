using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Model;
using System.Reflection;
using BLL.Interfaces;

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
    }
}
