using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Model;

namespace DAL.Interfaces
{
    public interface IPurchaseOrderDetailsRepository
    {
        List<PurchaseOrderDetailsModel> GetByPOID(int poid);

        bool CreateMultiple(List<PurchaseOrderDetailsModel> models); 
        
        bool Delete(PurchaseOrderDetailsModel model);
       

    }

}
