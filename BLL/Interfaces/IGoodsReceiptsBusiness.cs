using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Model;

namespace BLL.Interfaces
{
    public interface IGoodsReceiptsBusiness
    {
        GoodsReceiptsModel GetDatabyID(int id);
        bool CreateMultiple(List<GoodsReceiptsModel> models);
        bool Update(GoodsReceiptsModel model);

        bool Delete(GoodsReceiptsModel model);
    }
}
