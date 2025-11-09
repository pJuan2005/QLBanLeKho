using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model
{
    public class AuditLogModel
    {
        public int AuditID { get; set; }
        public int? UserID { get; set; }
        public string? Username { get; set; }
        public string? FullName { get;set; }
        public string Action {  get; set; }=string.Empty;
        public string? EntityName { get; set; }
        public int? EntityID { get; set; }
        public string Operation { get; set; } = string.Empty;
        public string? Details { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
