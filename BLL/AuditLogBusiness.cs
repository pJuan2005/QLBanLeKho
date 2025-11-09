using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Model;
using DAL;
using BLL.Interfaces;
using DAL.Interfaces;

namespace BLL
{
    public class AuditLogBusiness:IAuditLogBusiness
    {
        public IAuditLogRepository _res;
        public AuditLogBusiness(IAuditLogRepository res)
        {
            _res = res;
        }

        public bool Create(AuditLogModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            if (string.IsNullOrEmpty(model.Action))
            {
                model.Action = "UNKNOWN_ACTION";
            }

            if (string.IsNullOrEmpty(model.Operation))
            {
                model.Operation = "OTHER";
            }

            return _res.Create(model);
        }

        public AuditLogModel GetDataByID(int id)
        {
            return _res.GetDataByID(id);
        }

        public List<AuditLogModel>Search(int pageIndex, int pageSize, out long total,int? userId,string actionKeyword,string? operation,DateTime? fromDate,DateTime? toDate)
        {
            //chuẩn hoá keyword
            actionKeyword = string.IsNullOrEmpty(actionKeyword) ? null : actionKeyword.Trim();

            return _res.Search(pageIndex, pageSize,out total,userId,actionKeyword,operation,fromDate,toDate);
        }
    }
}
