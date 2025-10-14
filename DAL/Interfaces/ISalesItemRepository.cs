using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Model;

namespace DAL.Interfaces
{
    public interface ISalesItemRepository
    {
        SalesItemModel GetDatabyID(int saleID, int productID);
        bool Create(SalesItemModel model);
        
        bool Delete(SalesItemModel model);
    }
}
