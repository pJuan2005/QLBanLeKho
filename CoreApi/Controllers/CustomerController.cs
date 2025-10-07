using BLL;
using Model;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace CoreApi.Controllers
{
    [Route("api/customer")]
    [ApiController]
    public class CustomerController : ControllerBase
    {
        private ICustomerBusiness _customerBusiness;
        public CustomerController(ICustomerBusiness customerBusiness)
        {
            _customerBusiness = customerBusiness;
        }

        [Authorize(Roles =("Admin,ThuNgan,KeToan"))]
        [Route("get-by-id/{id}")]
        [HttpGet]
        public CustomerModel GetdatabyId(int id)
        {
            return _customerBusiness.GetdataById(id);
        }

        [Authorize(Roles =("Admin,ThuNgan"))]
        [Route("create-customer")]
        [HttpPost]
        public CustomerModel Create(CustomerModel model)
        {
            _customerBusiness.Create(model);
            return model;
        }

        [Authorize(Roles =("Admin,ThuNgan"))]
        [Route("update-customer")]
        [HttpPost]
        public CustomerModel Update(CustomerModel model)
        {
            _customerBusiness.Update(model);
            return model;
        }

        [Authorize(Roles =("Admin"))]
        [Route("delete-customer/{id}")]
        [HttpPost]
        public IActionResult DeleteCustomer(int id)
        {
            var ok = _customerBusiness.Delete(id);
            if(ok)
            {
                return Ok(new { message = "Đã xoá thành công" });
            }
            else
            {
                return Ok(new { message = "Xoá không thành công" });
            }

        }

        [Authorize(Roles =("Admin,ThuNgan,KeToan"))]
        [Route("search-customer")]
        [HttpPost]
        public ResponseModel Search([FromBody] Dictionary<string,object> formdata)
        {
            var respose = new ResponseModel();
            try
            {
                var pageIndex = int.Parse(formdata["pageIndex"].ToString());
                var pageSize = int.Parse(formdata["pageSize"].ToString()) ;
                string Phone = "";
                if (formdata.Keys.Contains("Phone") && !string.IsNullOrEmpty(Convert.ToString(formdata["Phone"])))
                {
                    Phone = Convert.ToString(formdata["Phone"]);
                }
                string Address = "";
                if(formdata.Keys.Contains("Address")&& !string.IsNullOrEmpty(Convert.ToString(formdata["Address"])))
                {
                    Address = Convert.ToString(formdata["Address"]);
                }

                var data = _customerBusiness.Search(pageIndex, pageSize,out long toal, Phone, Address);
                respose.TotalItems = toal;
                respose.Data = data;
                respose.Page = pageIndex;
                respose.PageSize = pageSize;

            }
            catch(Exception ex)
            {
                throw ex;
            }
            return respose;
        }

    }
}
