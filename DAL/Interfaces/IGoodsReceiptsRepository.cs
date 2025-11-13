using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Model;

namespace DAL.Interfaces
{
    public interface IGoodsReceiptsRepository
    {
        GoodsReceiptsModel GetDatabyID(int id);
        bool CreateMultiple(List<GoodsReceiptsModel> models);

        bool Update(GoodsReceiptsModel model);
        bool Delete(GoodsReceiptsModel model);
        List<GoodsReceiptsModel> Search(int pageIndex, int pageSize, out long total, decimal? minTotalAmount, decimal? maxTotalAmount, int? poid, DateTime? fromDate, DateTime? toDate);
    }
}
