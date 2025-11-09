using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Model;

namespace DAL.Interfaces
{
    public interface IAuditLogRepository
    {
        bool Create(AuditLogModel model);
        AuditLogModel GetDataByID(int id);
        List<AuditLogModel> Search(
            int pageIndex,
            int pageSize,
            out long total,
            int? userId,
            string actionKeyword,
            string? operation,
            DateTime? fromDate,
            DateTime? toDate
            );
    }
}
