using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Model;

namespace BLL.Interfaces
{
    public interface IPurchaseOrderDetailsBusiness
    {
        PurchaseOrderDetailsModel GetDatabyID(int poid, int productId);
      
        bool CreateMultiple(List<PurchaseOrderDetailsModel> models); // 👈 Thêm dòng này
    
        bool Delete(PurchaseOrderDetailsModel model);
    }

}
