using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using DAL;
using DAL.Interfaces;
using BLL.Interfaces;
using Model;
using DAL.Helper;

namespace BLL
{
    public class SalesBusiness : ISalesBusiness
    {
        private ISalesRepository _res;

        public SalesBusiness(ISalesRepository res)
        {
            _res = res;
        }

        public SalesModel GetDatabyID(int id)
        {
            return _res.GetDatabyID(id);
        }

        public bool Create(SalesModel model)
        {
            return _res.Create(model);
        }

        public bool Update(SalesModel model)
        {
            return _res.Update(model);
        }

        public bool Delete(SalesModel model)
        {
            return _res.Delete(model);
        }
    }
}
