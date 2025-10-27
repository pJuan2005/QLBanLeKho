using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Model;

namespace BLL.Interfaces
{
    public interface IGoodsReceiptDetailsBusiness
    {
        GoodsReceiptDetailsModel GetDatabyID(int receiptID);
        bool CreateMultiple(List<GoodsReceiptDetailsModel> models);
        
        bool Delete(GoodsReceiptDetailsModel model);
    }
}
