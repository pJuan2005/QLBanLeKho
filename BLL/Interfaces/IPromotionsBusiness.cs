using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Model;

namespace BLL.Interfaces
{
    public interface IPromotionsBusiness
    {
        PromotionsModel GetDatabyID(int id);
        bool Create(PromotionsModel model);
        bool Update(PromotionsModel model);
        bool Delete(PromotionsModel model);
    }
}
