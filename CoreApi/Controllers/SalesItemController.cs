﻿using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using BLL;
using System.Reflection;
using BLL.Interfaces;
using Model;

namespace CoreApi.Controllers
{
    [Route("api/salesitem")]
    [ApiController]
    public class SalesItemController : ControllerBase
    {
        private ISalesItemBusiness _salesItemBusiness;

        public SalesItemController(ISalesItemBusiness salesItemBusiness)
        {
            _salesItemBusiness = salesItemBusiness;
        }

        [Route("create")]
        [HttpPost]
        public SalesItemModel Create([FromBody] SalesItemModel model)
        {
            _salesItemBusiness.Create(model);
            return model;
        }

        [Route("update")]
        [HttpPost]
        public SalesItemModel Update([FromBody] SalesItemModel model)
        {
            _salesItemBusiness.Update(model);
            return model;
        }

        [Route("delete")]
        [HttpPost]
        public IActionResult Delete([FromBody] SalesItemModel model)
        {
            _salesItemBusiness.Delete(model);
            return Ok(new { data = "ok" });
        }

        [Route("get-by-id/{saleID}/{productID}")]
        [HttpGet]
        public SalesItemModel GetDatabyID(int saleID, int productID)
        {
            return _salesItemBusiness.GetDatabyID(saleID, productID);
        }
    }
}
