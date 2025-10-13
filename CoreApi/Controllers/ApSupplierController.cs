using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Model;
using BLL;
using BLL.Interfaces;
using Microsoft.AspNetCore.Authorization;

namespace CoreApi.Controllers
{
    [Route("api/apsupplier")]
    [ApiController]
    public class ApSupplierController : ControllerBase
    {
        public IApSupplierBusiness _business;
        public ApSupplierController(IApSupplierBusiness business)
        {
            _business = business;
        }

        [Authorize(Roles =("Admin,KeToan"))]
        [Route("search-apsupplier")]
        [HttpPost]
        public ResponseModel Search([FromBody] Dictionary<string, object> formdata)
        {
            var response = new ResponseModel();
            try
            {
                int pageIndex = int.Parse(formdata["pageIndex"].ToString());
                int pageSize = int.Parse(formdata["pageSize"].ToString());
                string search = "";
                if (formdata.ContainsKey("search") && !string.IsNullOrWhiteSpace(Convert.ToString(formdata["search"])))
                    search = Convert.ToString(formdata["search"]);
                var data = _business.Search(pageIndex, pageSize,out long total ,search);

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

        [Authorize(Roles=("Admin,KeToan"))]
        [Route("get-data-by-id/{id}")]
        [HttpGet]
        public ApSupplierModel.DetailAp GetDataById(int id)
        {
            return _business.GetdataById(id);
        }

    }
}
