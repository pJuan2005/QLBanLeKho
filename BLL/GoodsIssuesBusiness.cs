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
    public class GoodsIssuesBusiness : IGoodsIssuesBusiness
    {
        private IGoodsIssuesRepository _res;

        public GoodsIssuesBusiness(IGoodsIssuesRepository res)
        {
            _res = res;
        }

        public GoodsIssuesModel GetDatabyID(int id)
        {
            return _res.GetDatabyID(id);
        }

        public bool Create(GoodsIssuesModel model)
        {
            return _res.Create(model);
        }

        public bool Update(GoodsIssuesModel model)
        {
            return _res.Update(model);
        }

        public bool Delete(GoodsIssuesModel model)
        {
            return _res.Delete(model);
        }
    }
}
