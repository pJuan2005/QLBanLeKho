using Model;
using System.Collections.Generic;

namespace DAL.Interfaces
{
    public interface IDStockCardDAL
    {
        StockCardModel GetDatabyID(int id);
        bool Create(StockCardModel model);
        bool Update(StockCardModel model);
        bool Delete(int id);
        List<StockCardModel> Search(StockCardSearchRequest request, out long total);
    }
}
