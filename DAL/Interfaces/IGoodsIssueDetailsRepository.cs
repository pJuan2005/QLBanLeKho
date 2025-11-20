using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Model;

namespace DAL.Interfaces
{
    public interface IGoodsIssueDetailsRepository
    {
        List<GoodsIssueDetailsModel> GetDatabyID(int issueID);
        bool CreateMultiple(List<GoodsIssueDetailsModel> models);

        
        bool Delete(GoodsIssueDetailsModel model);
    }
}
