using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Model;

namespace BLL.Interfaces
{
    public interface IGoodsIssueDetailsBusiness
    {
        GoodsIssueDetailsModel GetDatabyID(int issueID, int productID);
        bool CreateMultiple(List<GoodsIssueDetailsModel> models);
       
        bool Delete(GoodsIssueDetailsModel model);
    }
}
