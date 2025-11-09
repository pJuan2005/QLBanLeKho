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
        List<PurchaseOrderDetailsModel> GetByPOID(int poid);

        bool CreateMultiple(List<PurchaseOrderDetailsModel> models); 
    
        bool Delete(PurchaseOrderDetailsModel model);
        
    }

}
