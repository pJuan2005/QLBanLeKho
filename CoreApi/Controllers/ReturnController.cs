using BLL.Interfaces;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Model;

namespace CoreApi.Controllers
{
    [Route("api/return")]
    [ApiController]
    public class ReturnController : ControllerBase
    {
        private readonly IDReturnBLL _ReturnBusiness;

        public ReturnController(IDReturnBLL returnID)
        {
            _ReturnBusiness = returnID;
        }

        [Route("create-return")]
        [HttpPost]
        public ReturnModel Create([FromBody] ReturnModel model)
        {
            _ReturnBusiness.Create(model);
            return model;
        }

        [Route("update-return")]
        [HttpPost]
        public ReturnModel Update([FromBody] ReturnModel model)
        {
            _ReturnBusiness.Update(model);
            return model;
        }

        [Route("delete-return/{id}")]
        [HttpDelete]
        public IActionResult Delete(int id)
        {
            _ReturnBusiness.Delete(id);
            return Ok(new { data = "OK" });
        }

        [Route("get-by-id/{id}")]
        [HttpGet]
        public ReturnModel GetDatabyID(int id)
        {
            return _ReturnBusiness.GetDatabyID(id);
        }

        //[Route("search-product")][HttpPost] public ResponseModel Search([FromBody] Dictionary<string, object> formData) { var response = new ResponseModel(); try { var page = int.Parse(formData["page"].ToString()); var pageSize = int.Parse(formData["pageSize"].ToString()); int? IDProduct = null; if (formData.Keys.Contains("IDProduct") && !string.IsNullOrEmpty(Convert.ToString(formData["IDProduct"]))) { IDProduct = Convert.ToInt32(formData["IDProduct"]); } string ProductName = ""; if (formData.Keys.Contains("ProductName") && !string.IsNullOrEmpty(Convert.ToString(formData["ProductName"]))) { ProductName = Convert.ToString(formData["ProductName"]); } string option = ""; if (formData.Keys.Contains("option") && !string.IsNullOrEmpty(Convert.ToString(formData["option"]))) { option = Convert.ToString(formData["option"]); } long total = 0; var data = _ProductBusiness.Search(page, pageSize, out total, IDProduct, ProductName, option); response.TotalItems = total; response.Data = data; response.Page = page; response.PageSize = pageSize; } catch (Exception ex) { throw new Exception(ex.Message); } return response; }

        [Route("search-product")]
        [HttpPost]
        public ResponseModel Search([FromBody] ReturnSearchRequest request)
        {
            var response = new ResponseModel();
            try
            {
                long total = 0;
                var data = _ReturnBusiness.Search(
                    request.page,
                    request.pageSize,
                    out total,
                    request.ReturnID,
                    request.SaleID,
                    request.CustomerID,
                    request.FromDate,
                    request.ToDate
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

