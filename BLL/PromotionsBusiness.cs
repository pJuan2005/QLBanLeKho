using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using DAL;
using DAL.Interfaces;
using BLL.Interfaces;
using Model;
using DAL.Helper;

namespace BLL
{
    public class PromotionsBusiness : IPromotionsBusiness
    {
        private IPromotionsRepository _res;

        public PromotionsBusiness(IPromotionsRepository res)
        {
            _res = res;
        }
        public PromotionsModel GetDatabyID(int id)
        {
            return _res.GetDatabyID(id);
        }

        public bool Create(PromotionsModel model)
        {
            return _res.Create(model);
        }

        public bool Update(PromotionsModel model)
        {
            return _res.Update(model);
        }

        public bool Delete(PromotionsModel model)
        {
            return _res.Delete(model);
        }

    }
}
