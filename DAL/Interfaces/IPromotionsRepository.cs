using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Model;

namespace DAL.Interfaces
{
    public interface IPromotionsRepository
    {
        PromotionsModel GetDatabyID(int id);
        bool Create(PromotionsModel model);
        bool Update(PromotionsModel model);
        bool Delete(PromotionsModel model);
        List<PromotionsModel> Search(int pageIndex, int pageSize, out long total, DateTime? fromDate, DateTime? toDate, string status);
    }
}
