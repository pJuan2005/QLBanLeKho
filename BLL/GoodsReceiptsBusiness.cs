using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Model;
using BLL.Interfaces;
using DAL;
using DAL.Interfaces;

namespace BLL
{
    public class GoodsReceiptsBusiness : IGoodsReceiptsBusiness
    {

        private IGoodsReceiptsRepository _res;
        public GoodsReceiptsBusiness(IGoodsReceiptsRepository res)
        {
            _res = res;
        }

        public GoodsReceiptsModel GetDatabyID(int id)
        {
            return _res.GetDatabyID(id);
        }

        public int Create(GoodsReceiptsModel model)
        {
            return _res.Create(model);
        }

        public bool Update(GoodsReceiptsModel model)
        {
            return (_res.Update(model));
        }
        public bool Delete(GoodsReceiptsModel model)
        {
            return _res.Delete(model);
        }

        public List<GoodsReceiptsModel> Search(int pageIndex, int pageSize, out long total, decimal? minTotalAmount, decimal? maxTotalAmount, int? poid, DateTime? fromDate, DateTime? toDate)
        {
            return _res.Search(pageIndex, pageSize, out total,
                minTotalAmount, maxTotalAmount, poid, fromDate, toDate);
        }

    }
}
