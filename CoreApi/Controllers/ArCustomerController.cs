using BLL;
using Model;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using BLL.Interfaces;

namespace CoreApi.Controllers
{
    [Route("api/ar_customer")]
    [ApiController]
    public class ArCustomerController : ControllerBase
    {
        public IArCustomerBusiness _business;
        public ArCustomerController(IArCustomerBusiness business)
        {
            _business = business;
        }

        [Authorize(Roles = ("Admin,ThuNgan,KeToan"))]
        [Route("search-customers")]
        [HttpPost]
        public ResponseModel Search([FromBody] Dictionary<string, object> formdata)
        {
            var response = new ResponseModel();
            try
            {
                int pageIndex = int.Parse(formdata["pageIndex"].ToString());
                int pageSize = int.Parse(formdata["pageSize"].ToString()) ;

                string search = "";
                if (formdata.ContainsKey("search") && !string.IsNullOrWhiteSpace(Convert.ToString(formdata["search"])))
                    search = Convert.ToString(formdata["search"])!;
                var data = _business.Search(pageIndex, pageSize, out long total, search);

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

        [Authorize(Roles =("Admin,ThuNgan,KeToan"))]
        [Route("search-by-id/{id}")]
        [HttpGet]
        public ArCustomerModel.DetailAr GetdataByID(int id)
        {
            return _business.GetDetail(id);
        }

        [Authorize(Roles =("Admin,ThuNgan,KeToan"))]
        [Route("check-limit")]
        [HttpGet]
        public ArCustomerModel.CheckLimitResult CheckLimit([FromQuery] int id, [FromQuery] decimal newAmount, [FromQuery] decimal prepay = 0)
        {
            return _business.CheckLimit(id, newAmount, prepay);
        }
    }
}
