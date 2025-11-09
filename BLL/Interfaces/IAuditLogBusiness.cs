using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using DAL;
using Model;

namespace BLL.Interfaces
{
    public interface IAuditLogBusiness
    {
        bool Create(AuditLogModel model);
        AuditLogModel GetDataByID(int id);
        List<AuditLogModel> Search(int pageIndex, int pageSize, out long total, int? userId, string actionKeyWord,string? operation, DateTime? fromDate, DateTime? toDate);
    }
}
