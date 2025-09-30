using BLL.Interfaces;
using DAL.Interfaces;
using Model;
using System;
using System.Collections.Generic;

namespace BLL
{
    public class StockCardBLL : IDStockCardBLL
    {
        private readonly IDStockCardDAL _res;

        public StockCardBLL(IDStockCardDAL res)
        {
            _res = res;
        }

        public StockCardModel GetDatabyID(int id)
        {
            return _res.GetDatabyID(id);
        }

        public bool Create(StockCardModel model)
        {
            if (model == null) throw new ArgumentNullException(nameof(model));
            return _res.Create(model);
        }

        public bool Update(StockCardModel model)
        {
            if (model == null) throw new ArgumentNullException(nameof(model));
            return _res.Update(model);
        }

        public bool Delete(int id)
        {
            return _res.Delete(id);
        }

        public List<StockCardModel> Search(int pageIndex, int pageSize, out long total,
                                           int? StockID,
                                           int? ProductID,
                                           string TransactionType,
                                           int? RefID,
                                           string option)
        {
            return _res.Search(pageIndex, pageSize, out total, StockID, ProductID, TransactionType, RefID, option);
        }
    }
}
