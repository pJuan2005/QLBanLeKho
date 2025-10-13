using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model
{
    public class StockCardModel
    {
        public int StockID { get; set; }            
        public int ProductID { get; set; }          
        public string TransactionType { get; set; } 
        public int Quantity { get; set; }           
        public int Balance { get; set; }            
        public int? RefID { get; set; }             
        public DateTime TransactionDate { get; set; }      
    }

    public class StockCardSearchRequest
    {
        public int page { get; set; }
        public int pageSize { get; set; }
        public int? StockID { get; set; }            
        public int? ProductID { get; set; }          
        public string? TransactionType { get; set; } 
        public int? RefID { get; set; }              
        public string? Status { get; set; }          
    }
}





