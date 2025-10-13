using BLL.Interfaces;
using DAL.Interfaces;
using Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BLL
{
    public class ReturnBLL : IDReturnBLL
    {
        private readonly IDReturnDAL _res;

        public ReturnBLL(IDReturnDAL res)
        {
            _res = res;
        }

        public ReturnModel GetDatabyID(int id)
        {
            return _res.GetDatabyID(id);
        }

        public bool Create(ReturnModel model)
        {
            return _res.Create(model);
        }

        public bool Update(ReturnModel model)
        {
            return _res.Update(model);
        }

        public bool Delete(int id)
        {
            return _res.Delete(id);
        }

        public List<ReturnModel> Search(int pageIndex, int pageSize, out long total,
                                  int? ReturnID, int? SaleID, int? CustomerID,
                                  DateTime? FromDate, DateTime? ToDate)
        {
            return _res.Search(pageIndex, pageSize, out total, ReturnID, SaleID, CustomerID, FromDate, ToDate);
        }
    }
}
