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
        bool Create(GoodsIssueDetailsModel model);
        bool Update(GoodsIssueDetailsModel model);
        bool Delete(GoodsIssueDetailsModel model);
    }
}
