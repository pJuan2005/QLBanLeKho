using Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAL.Interfaces
{
    public partial interface IPurchaseOrderRepository
    {
        PurchaseOrderModel GetDatabyID(int id);
        bool CreateMultiple(List<PurchaseOrderModel> models);
        bool Update(PurchaseOrderModel model);
        bool Delete(PurchaseOrderModel model);
        List<PurchaseOrderModel> Search(int pageIndex, int pageSize, out long total, int? SupplierID, DateTime? OrderDate, decimal TotalAmount);
    }
}
