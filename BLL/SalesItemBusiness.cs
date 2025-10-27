using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Model;
using DAL.Interfaces;
using DAL;
using BLL.Interfaces;
using DAL.Helper;

namespace BLL
{
    public class SalesItemBusiness : ISalesItemBusiness
    {
        private ISalesItemRepository _res;

        public SalesItemBusiness(ISalesItemRepository res)
        {
            _res = res;
        }

        public SalesItemModel GetDatabyID(int saleID, int productID)
        {
            return _res.GetDatabyID(saleID, productID);
        }

        public bool CreateMultiple(List<SalesItemModel> models) 
        {
            return _res.CreateMultiple(models);
        }

        
        public bool Delete(SalesItemModel model)
        {
            return _res.Delete(model);
        }
    }
}
