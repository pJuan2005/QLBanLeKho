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
        List<PurchaseOrderModel> Search(decimal? minTotalAmount, decimal? maxTotalAmount, string status, DateTime? fromDate, DateTime? toDate );
    }
}
