using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Model;

namespace Model
{
    public class SalesItemModel
    {
        public int SaleID { get; set; }       
        public int ProductID { get; set; }  
        public string? ProductName { get; set; }
        public int Quantity { get; set; }       
        public decimal UnitPrice { get; set; }  
        public decimal Discount { get; set; }
    }
}
