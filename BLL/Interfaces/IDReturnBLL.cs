using Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BLL.Interfaces
{
    public interface IDReturnBLL
    {
        ReturnModel GetDatabyID(int returnId);
        bool Create(ReturnModel model);
        bool Update(ReturnModel model);
        bool Delete(int returnId);
        List<ReturnModel> Search(int pageIndex, int pageSize, out long total,
                                  int? ReturnID, int? SaleID, int? CustomerID,
                                  DateTime? FromDate, DateTime? ToDate);
    }
}
