using DAL.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Model;
using DAL.Helper;

namespace DAL
{
    public class AuditLogRepository: IAuditLogRepository
    {
        public IDatabaseHelper _dbHelper;

        public AuditLogRepository(IDatabaseHelper dbHelper)
        {
            _dbHelper = dbHelper;
        }

        public bool Create(AuditLogModel model)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(
                    out msgError,
                    "sp_auditlog_create",
                    "@UserId",model.UserID,
                    "@Username",model.Username,
                    "@FullName",model.FullName,
                    "@Action",model.Action,
                    "@EntityName",model.EntityName,
                    "@EntityId",model.EntityID,
                    "@Operation",model.Operation,
                    "@Details",model.Details
                    );
                if (!string.IsNullOrEmpty(msgError))
                {
                    throw new Exception(msgError);
                }
                if (result == null || !int.TryParse(result.ToString(), out int newId))
                    throw new Exception("Tạo audit log thất bại, không lấy được id trả về");
                model.AuditID = newId;
                return true;
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }

        public AuditLogModel GetDataByID(int id)
        {
            string msgError = "";
            try
            {
                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msgError,
                    "sp_auditlog_get_by_id",
                    "@AuditId", id);
                if(!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);
                return dt.ConvertTo<AuditLogModel>().FirstOrDefault();
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }

        public List<AuditLogModel>Search(
            int pageIndex,
            int pageSize,
            out long total,
            int? userId,
            string actionKeyword,
            string? operation,
            DateTime?fromDate,
            DateTime?toDate)
        {
            string msgError = "";
            total = 0;
            try
            {
                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(
                    out msgError,
                    "sp_auditlog_search",
                    "@pageIndex",pageIndex,
                    "@pageSize",pageSize,
                    "@userId",userId,
                    "@actionKeyword",actionKeyword,
                    "@operation", operation,
                    "@fromDate",fromDate,
                    "@toDate",toDate);
                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);
                if (dt.Rows.Count > 0 && dt.Columns.Contains("RecordCount"))
                    total = Convert.ToInt64(dt.Rows[0]["RecordCount"]);
                return dt.ConvertTo<AuditLogModel>().ToList();
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }
    }
}
