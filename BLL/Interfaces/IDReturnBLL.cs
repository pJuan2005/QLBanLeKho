using Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BLL.Interfaces
{
    public interface IReturnBLL
    {
        ReturnModel GetDatabyID(int returnId);
        int Create(ReturnCreateRequest model);
        bool Update(ReturnUpdateRequest model);
        bool Delete(int id);
        List<ReturnModel> Search(int pageIndex, int pageSize, out long total,
                                int? ReturnID, byte? ReturnType,
                                int? SaleID, int? POID,
                                int? CustomerID, int? SupplierID,
                                string? PartnerName, string? PartnerPhone,
                                int? ProductID,
                                DateTime? FromDate, DateTime? ToDate);
    }
}
