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
    public class GoodsIssueDetailsBusiness : IGoodsIssueDetailsBusiness
    {
        private IGoodsIssueDetailsRepository _res;

        public GoodsIssueDetailsBusiness(IGoodsIssueDetailsRepository res)
        {
            _res = res;
        }

        public GoodsIssueDetailsModel GetDatabyID(int issueID, int productID)
        {
            return _res.GetDatabyID(issueID, productID);
        }

        public bool Create(GoodsIssueDetailsModel model)
        {
            return _res.Create(model);
        }

        public bool Update(GoodsIssueDetailsModel model)
        {
            return _res.Update(model);
        }

        public bool Delete(GoodsIssueDetailsModel model)
        {
            return _res.Delete(model);
        }
    }
}
