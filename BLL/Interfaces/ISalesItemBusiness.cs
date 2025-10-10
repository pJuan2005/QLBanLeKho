using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Model;

namespace BLL.Interfaces
{
    public interface ISalesItemBusiness
    {
        SalesItemModel GetDatabyID(int saleID, int productID);
        bool Create(SalesItemModel model);
        bool Update(SalesItemModel model);
        bool Delete(SalesItemModel model);
    }
}
