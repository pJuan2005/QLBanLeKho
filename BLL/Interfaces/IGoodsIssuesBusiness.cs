using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Model;

namespace BLL.Interfaces
{
    public interface IGoodsIssuesBusiness
    {
        GoodsIssuesModel GetDatabyID(int id);
        int Create(GoodsIssuesModel model);
        bool Update(GoodsIssuesModel model);
        bool Delete(GoodsIssuesModel model);
        List<GoodsIssuesModel> Search(int pageIndex, int pageSize, out long total, int? userId, DateTime? fromDate, DateTime? toDate);
        }
}
