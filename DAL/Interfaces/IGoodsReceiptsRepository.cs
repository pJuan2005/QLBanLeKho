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
        bool Create(GoodsReceiptsModel model);
        bool Update(GoodsReceiptsModel model);
        bool Delete(GoodsReceiptsModel model);
    }
}
