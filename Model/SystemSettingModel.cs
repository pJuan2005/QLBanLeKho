using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model
{
    public class SystemSettingModel
    {
        public int SettingID { get; set; }
        public string SettingKey { get; set; }
        public string SettingValue { get; set; }
        public string Description { get; set; }
        public DateTime UpdatedDate { get; set; }
        public string UpdatedBy { get; set; }
    }

    public class SystemSettingSearchRequest
    {
        public int page { get; set; }
        public int pageSize { get; set; }
        public string SettingKey { get; set; }
        public string Description { get; set; }
        public string option { get; set; }
    }
}

