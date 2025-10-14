using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model
{
    public class SystemSettingModel
    {
        public int? SettingID { get; set; }
        public string? Setting { get; set; }
        public string? Information { get; set; }
    }


    public class SystemSettingSearchRequest
    {
        public int page { get; set; }
        public int pageSize { get; set; }
        public int? SettingID { get; set; }
        public string? Setting { get; set; }
        public string? Information { get; set; }

    }
}
