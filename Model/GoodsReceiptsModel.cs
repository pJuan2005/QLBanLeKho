using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Model;

namespace Model
{
    public class GoodsReceiptsModel
    {
        public int ReceiptID { get; set; }
        public int POID { get; set; }
        public DateTime ReceiptDate { get; set; }
        public decimal TotalAmount { get; set; }
        public int UserID { get; set; }
        public string? BatchNo { get; set; } 
        public string? Status { get; set; }
    }

}
