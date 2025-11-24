namespace Model
{
    public class ReportRevenueRequest
    {
        public string FromDate { get; set; }
        public string ToDate { get; set; }
        public string Option { get; set; } // "DAY" , "MONTH"



    }

    public class ReportRevenueResponse
    {
        public string Date { get; set; }    // yyyy-MM hoặc yyyy-MM-dd
        public decimal Revenue { get; set; }
        public decimal GrossProfit { get; set; }


        public string BestCategory { get; set; }
        public string TopProduct { get; set; }
        public string BestSupplier { get; set; }
    }

    public class ReportImportExportResponse
    {
        public string Date { get; set; }   // yyyy-MM-dd hoặc yyyy-MM theo option

        public int ImportQty { get; set; }
        public int ExportQty { get; set; }

        // KPI
        public int TotalImportQty { get; set; }
        public int TotalExportQty { get; set; }

        public string TopImportedProduct { get; set; }
        public string LeastImportedProduct { get; set; }

        public string TopExportedProduct { get; set; }
        public string LeastExportedProduct { get; set; }
    }


    public class ReportStockResponse
    {
        public int ProductID { get; set; }
        public string SKU { get; set; }
        public string ProductName { get; set; }
        public string BatchNo { get; set; }
        public DateTime FirstReceiptDate { get; set; }
        public int QtyIn { get; set; }
        public int QtyRemain { get; set; }
        public int AgeInDays { get; set; }
        public int MinStock { get; set; }


        public decimal TotalStockValue { get; set; }
        public int LowStockCount { get; set; }
        public int MinDaysToExpire { get; set; }
        public decimal UnitPrice { get; set; }
        public DateTime? ExpiryDate { get; set; }

    }
}


namespace Model
{
    public class ReportTopProductResponse
    {
        public string ProductName { get; set; }
        public int TotalQty { get; set; }
        public decimal Percent { get; set; }
    }
}
