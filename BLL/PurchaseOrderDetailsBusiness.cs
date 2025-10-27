using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BLL.Interfaces;
using DAL;
using DAL.Interfaces;
using Model;


namespace BLL
{
    public class PurchaseOrderDetailsBusiness : IPurchaseOrderDetailsBusiness
    {
        private IPurchaseOrderDetailsRepository _res;

        public PurchaseOrderDetailsBusiness(IPurchaseOrderDetailsRepository res)
        {
            _res = res;
        }

        public PurchaseOrderDetailsModel GetDatabyID(int poid, int productId)
        {
            return _res.GetDatabyID(poid, productId);
        }

      

        public bool CreateMultiple(List<PurchaseOrderDetailsModel> models) 
        {
            return _res.CreateMultiple(models);
        }

       

        public bool Delete(PurchaseOrderDetailsModel model)
        {
            return _res.Delete(model);
        }
    }

}
