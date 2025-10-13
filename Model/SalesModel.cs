using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Model;

namespace Model
{
    public class SalesModel
    {
        public int SaleID { get; set; }           
        public int CustomerID { get; set; }       
        public int UserID { get; set; }           
        public DateTime SaleDate { get; set; }    
        public decimal TotalAmount { get; set; }  
        public decimal VATAmount { get; set; }    
        public string? PaymentStatus { get; set; } 
    }

}
