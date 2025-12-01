using BLL.Interfaces;
using DAL;
using DAL.Interfaces;
using Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;


namespace BLL
{
    public class ReturnBLL : IReturnBLL
    {
        private readonly IReturnDAL _res;

        public ReturnBLL(IReturnDAL res)
        {
            _res = res;
        }

        public ReturnModel GetDatabyID(int id)
        {
            return _res.GetDatabyID(id);
        }

        public int Create(ReturnCreateRequest model)
        {
            return _res.Create(model);
        }

        public bool Update(ReturnUpdateRequest model)
        {
            return _res.Update(model);
        }

        public bool Delete(int id)
        {
            return _res.Delete(id);
        }


        public List<ReturnModel> Search(int pageIndex, int pageSize, out long total,
        int? ReturnID, byte? ReturnType,
        int? SaleID, int? POID,
        int? CustomerID, int? SupplierID,
        string? PartnerName, string? PartnerPhone,
        int? ProductID,
        DateTime? FromDate, DateTime? ToDate)
        {
            return _res.Search(pageIndex, pageSize, out total,
            ReturnID, ReturnType,
            SaleID, POID,
            CustomerID, SupplierID,
            PartnerName, PartnerPhone,
            ProductID,
            FromDate, ToDate);
        }
    }
}
