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

        public List<GoodsIssueDetailsModel> GetDatabyID(int issueID)
        {
            return _res.GetDatabyID(issueID);
        }


        public bool CreateMultiple(List<GoodsIssueDetailsModel> models)
        {
            return _res.CreateMultiple(models);
        }

     

        public bool Delete(GoodsIssueDetailsModel model)
        {
            return _res.Delete(model);
        }
    }
}
