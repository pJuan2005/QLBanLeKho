using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Model;

namespace DAL.Interfaces
{
    public interface IGoodsReceiptDetailsRepository
    {
        List<GoodsReceiptDetailsModel> GetDatabyID(int receiptID);

        bool CreateMultiple(List<GoodsReceiptDetailsModel> models);
      
        bool Delete(GoodsReceiptDetailsModel model);
    }
}

