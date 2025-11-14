using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model
{
    public class StockCardModel
    {
        public int? StockID { get; set; }            
        public int? ProductID { get; set; }
        public string? ProductName { get; set; }
        public string? TransactionType { get; set; } 
        public int? Quantity { get; set; }           
        public int? Balance { get; set; }
        public int? ReceiptID { get; set; }
        public int? IssueID { get; set; }
        public int? SupplierID { get; set; }
        public string? BatchNo { get; set; }       
        public DateTime TransactionDate { get; set; }      
    }




    public class StockCardSearchRequest
    {
        public int page {get; set; }
        public int pageSize { get; set; }
        public int? StockID { get; set; }            
        public int? ProductID { get; set; }
        public string? ProductName { get; set; }
        public string? TransactionType { get; set; }
        public int? Balance { get; set; }
        public int? ReceiptID { get; set; }
        public int? IssueID { get; set; }
        public int? SupplierID { get; set; }
        public string? BatchNo { get; set; }
        public DateTime? FromDate { get; set; }
        public DateTime? ToDate { get; set; }


    }
}





