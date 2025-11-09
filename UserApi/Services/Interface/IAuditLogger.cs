namespace AdminApi.Services.Interface
{
    public interface IAuditLogger
    {
        void Log(
            string action,
            string? entityName,
            int? entityId,
            string operation,
            string? details = null,
            int? userId = null,
            string? username = null,
            string? fullName = null);
    }
}
