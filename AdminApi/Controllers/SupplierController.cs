using BLL;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Model;

namespace AdminApi.Controllers
{
    [Route("api/supplier")]
    [ApiController]
    public class SupplierController : ControllerBase
    {
        private ISupplierBusiness _supplierbusiness;
        public SupplierController(ISupplierBusiness supplierbusiness)
        {
            _supplierbusiness = supplierbusiness;
        }

        [Authorize(Roles =("Admin,ThuKho"))]
        [Route("create-supplier")]
        [HttpPost]
        public SupplierModel Create(SupplierModel model)
        {
            _supplierbusiness.Create(model);
            return model;
        }

        [Authorize(Roles=("Admin,ThuKho"))]
        [Route("update-supplier")]
        [HttpPost]
        public SupplierModel Update(SupplierModel model)
        {
            _supplierbusiness.Update(model);
            return model;
        }

        [Authorize(Roles =("Admin"))]
        [Route("delete-supplier/{id}")]
        [HttpPost]
        public IActionResult DeleteSupplier( int id)
        {
            var ok = _supplierbusiness.Delete(id);
            if(ok)
            {
                return Ok(new { message = "Đã xoá thành công!" });
            }
            else
            {
                return Ok(new { message = "Xoá không thành công" });
            }
        }

        [Authorize(Roles =("Admin,ThuKho,KeToan"))]
        [Route("get-by-id/{id}")]
        [HttpGet]
        public SupplierModel GetdataByID(int id)
        {
            return _supplierbusiness.GetdataByID(id);
        }

        [Authorize(Roles ="Admin,ThuKho,KeToan")]
        [Route("search")]
        [HttpPost]
        public ResponseModel Search([FromBody] Dictionary<string,object> formdata)
        {
            var response = new ResponseModel();
            try
            {
                var pageIndex= int.Parse(formdata["pageIndex"].ToString());
                var pageSize = int.Parse(formdata["pageSize"].ToString());
                string Phone = "";
                if (formdata.Keys.Contains("Phone") && !string.IsNullOrEmpty(Convert.ToString(formdata["Phone"])))
                { Phone = Convert.ToString(formdata["Phone"]); }
                var data = _supplierbusiness.Search(pageIndex, pageSize,out long total, Phone);
                response.TotalItems = total;
                response.Data = data;
                response.Page = pageIndex;
                response.PageSize = pageSize;

            }
            catch(Exception ex)
            {
                throw ex;
            }
            return response;
        }
    }
}
