using System;
using System.Security.Claims;
using BLL.Interfaces;
using Model;
using Microsoft.AspNetCore.Http;
using AdminApi.Services.Interface;

namespace CoreApi.Services
{
    public class AuditLogger : IAuditLogger
    {
        private readonly IAuditLogBusiness _bus;
        private readonly IHttpContextAccessor _contextAccessor;

        public AuditLogger(IAuditLogBusiness bus, IHttpContextAccessor contextAccessor)
        {
            _bus = bus;
            _contextAccessor = contextAccessor;
        }

        public void Log(
            string action,
            string? entityName,
            int? entityId,
            string operation,
            string? details = null,
            int? userId = null,
            string? username = null,
            string? fullName = null)
        {
            try
            {
                var httpContext = _contextAccessor.HttpContext;

                // Nếu chưa truyền userId/username/fullName thì thử lấy từ JWT
                if (httpContext != null)
                {
                    var user = httpContext.User;

                    if (userId == null)
                    {
                        var claim = user.FindFirst("UserId") ?? user.FindFirst(ClaimTypes.NameIdentifier);
                        if (claim != null && int.TryParse(claim.Value, out int id))
                            userId = id;
                    }

                    username ??= user.FindFirst("Username")?.Value
                                  ?? user.FindFirst(ClaimTypes.Name)?.Value;

                    fullName ??= user.FindFirst("FullName")?.Value;
                }

                var logModel = new AuditLogModel
                {
                    UserID = userId,
                    Username = username,
                    FullName = fullName,
                    Action = action,
                    EntityName = entityName,
                    EntityID = entityId,
                    Operation = operation,
                    Details = details,
                    CreatedAt = DateTime.Now
                };

                _bus.Create(logModel);
            }
            catch
            {
                // Không để lỗi log làm hỏng nghiệp vụ
            }
        }
    }
}
