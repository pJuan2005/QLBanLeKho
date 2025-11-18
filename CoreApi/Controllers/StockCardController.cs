using BLL.Interfaces;
using Microsoft.AspNetCore.Mvc;
using Model;
using System;

namespace CoreApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class StockCardController : ControllerBase
    {
        private readonly IDStockCardBLL _stockCardBLL;

        public StockCardController(IDStockCardBLL stockCardBLL)
        {
            _stockCardBLL = stockCardBLL;
        }

        [Route("get-by-id/{id}")]
        [HttpGet]
        public StockCardModel GetByID(int id)
        {
            return _stockCardBLL.GetDatabyID(id);
        }

        [Route("create-stockcard")]
        [HttpPost]
        public StockCardModel Create([FromBody] StockCardModel model)
        {
            _stockCardBLL.Create(model);
            return model;
        }

        [Route("update")]
        [HttpPut]
        public StockCardModel Update([FromBody] StockCardModel model)
        {
            _stockCardBLL.Update(model);
            return model;
        }



        [HttpDelete("delete/{id}")]
        public IActionResult Delete(int id)
        {
            var ok = _stockCardBLL.Delete(id);

            if (!ok)
                return NotFound(new { message = "Stockcard not found" });

            return Ok(new { message = "Delete success" });
        }


        [Route("search-stockcard")]
        [HttpPost]
        public ResponseModel Search([FromBody] StockCardSearchRequest request)
        {
            var response = new ResponseModel();
            try
            {
                long total = 0;
                var data = _stockCardBLL.Search(request, out total);

                response.TotalItems = total;
                response.Data = data;
                response.Page = request.page;
                response.PageSize = request.pageSize;
            
            }
            catch (Exception ex)
                {
                    throw new Exception(ex.Message);
                }
            return response;
        }
    }
}
