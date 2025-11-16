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
        int Create(GoodsReceiptsModel model);
        bool Update(GoodsReceiptsModel model);

        bool Delete(GoodsReceiptsModel model);
        List<GoodsReceiptsModel> Search(int pageIndex, int pageSize, out long total, decimal? minTotalAmount, decimal? maxTotalAmount, int? poid, DateTime? fromDate, DateTime? toDate);
    }
}
