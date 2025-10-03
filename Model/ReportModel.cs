using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model
{
    public class ReportRevenueRequest
    {
        public DateTime FromDate { get; set; }
        public DateTime ToDate { get; set; }
        public string Option { get; set; } // "DAY", "MONTH", "SHIFT"
    }

    public class ReportRevenueResponse
    {
        public DateTime Date { get; set; }
        public decimal Revenue { get; set; }
        public decimal GrossProfit { get; set; }
    }

    public class ReportImportExportResponse
    {
        public DateTime Date { get; set; }
        public int ImportQty { get; set; }
        public int ExportQty { get; set; }
    }

    public class ReportStockResponse
    {
        public int ProductID { get; set; }
        public string ProductName { get; set; }
        public int CurrentStock { get; set; }
        public int MinStock { get; set; }
        public int AgeInDays { get; set; }
    }


}
