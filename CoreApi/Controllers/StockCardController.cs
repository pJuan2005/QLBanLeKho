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

        [Route("delete/{id}")]
        [HttpDelete]
        public IActionResult Delete(int id)
        {
            _stockCardBLL.Delete(id);
            return Ok(new { data = "OK" });
        }

        [Route("search-stockcard")]
        [HttpPost]
        public ResponseModel Search([FromBody] StockCardSearchRequest request)
        {
            var response = new ResponseModel();
            try
            {
                long total = 0;
                var data = _stockCardBLL.Search(
                    request.page,
                    request.pageSize,
                    out total,
                    request.StockID,
                    request.ProductID,
                    request.TransactionType,
                    request.RefID,
                    request.option
                );

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
