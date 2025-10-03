using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Model;

namespace BLL.Interfaces
{
    public  interface IPurchaseOrderDetailsBusiness
    {
        PurchaseOrderDetailsModel GetDatabyID(int poid, int productId);
        bool Create(PurchaseOrderDetailsModel model);
        bool Update(PurchaseOrderDetailsModel model);
        bool Delete(PurchaseOrderDetailsModel model);
    }
}
