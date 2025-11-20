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

    public class PosOrderDto
    {
        public int CustomerId { get; set; }
        public int UserId { get; set; } 

        // DÙNG LẠI SalesItemModel
        public List<SalesItemModel> Items { get; set; } = new List<SalesItemModel>();

        // Thanh toán
        public decimal Prepay { get; set; }            // Khách trả
        public string PaymentMethod { get; set; } = "Cash";
        public DateTime PaymentDate { get; set; } = DateTime.Now;

        // Tổng tiền đơn mà FE tính (sau VAT) – optional, chỉ để so sánh/debug
        public decimal ClientTotal { get; set; }
    }

    public class PosSaleResult
    {
        public SalesModel Sale { get; set; }    // Thông tin đơn
        public decimal BeforeDebt { get; set; } // Nợ trước khi mua
        public decimal NewRemainingDebt { get; set; } // Nợ sau đơn này
    }

}
