using Model;
using System.Collections.Generic;

namespace BLL.Interfaces
{
    public interface IDStockCardBLL
    {
        StockCardModel GetDatabyID(int id);
        bool Create(StockCardModel model);
        bool Update(StockCardModel model);
        bool Delete(int id);

        List<StockCardModel> Search(StockCardSearchRequest request, out long total);
    }
}
