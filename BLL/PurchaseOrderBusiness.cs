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
    public class PurchaseOrderBusiness : IPurchaseOrderBusiness
    {
        private IPurchaseOrderRepository _res;
        public PurchaseOrderBusiness(IPurchaseOrderRepository res)
        {
            _res = res;
        }
        public PurchaseOrderModel GetDatabyID(int id)
        {
            return _res.GetDatabyID(id);
        }
        public bool CreateMultiple(List<PurchaseOrderModel> models) // 👈 Thêm phương thức này
        {
            return _res.CreateMultiple(models);
        }
        public bool Update(PurchaseOrderModel model)
        {
            return _res.Update(model);
        }
        public bool Delete(PurchaseOrderModel model)
        {
            return _res.Delete(model);
        }
        public List<PurchaseOrderModel> Search(int pageIndex, int pageSize, out long total, int? SupplierID, DateTime? OrderDate, decimal TotalAmount)
        {
            return _res.Search(pageIndex, pageSize, out total, SupplierID, OrderDate, TotalAmount);
        }
    }
}
