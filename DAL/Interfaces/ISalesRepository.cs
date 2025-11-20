using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Model;

namespace DAL.Interfaces
{
    public interface ISalesRepository
    {
        SalesModel GetDatabyID(int id);
        SaleDetailDto GetDetail(int saleId);
        bool Create(SalesModel model);
        bool Update(SalesModel model);
        bool Delete(SalesModel model);
        List<SalesModel> Search(int pageIndex, int pageSize, out long total, decimal? minTotalAmount, decimal? maxTotalAmount, string status, DateTime? fromDate, DateTime? toDate);
        int CreateReturnId(SalesModel model);
        List<SalesListItemDto> SearchList(
            int pageIndex, int pageSize, out long total,
            string status, DateTime? fromDate, DateTime? toDate,
            string keyword
        );
        SalesDashboardDto GetDashboard(
        decimal? minTotalAmount, decimal? maxTotalAmount,
        string status, DateTime? fromDate, DateTime? toDate,
        string keyword // search invoice or customer
    );
    }
}
