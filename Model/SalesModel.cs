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

    public class SalesDashboardDto
    {
        public int TotalSales { get; set; }        // số hóa đơn
        public decimal TotalRevenue { get; set; }  // tổng tiền
        public decimal AvgOrderValue { get; set; } // doanh thu TB / đơn
        public int PaidCount { get; set; }         // số đơn Paid
        public int UnpaidCount { get; set; }       // số đơn Unpaid/Partial
    }

    public class SalesListItemDto
    {
        public int SaleID { get; set; }
        public string InvoiceNo { get; set; }          
        public DateTime SaleDate { get; set; }

        public int CustomerID { get; set; }
        public string CustomerName { get; set; }

        public decimal TotalAmount { get; set; }
        public string PaymentStatus { get; set; }

        public string PaymentMethod { get; set; }      
        public long RecordCount { get; set; }          
    }

    //dto cho in và xem chi tiết đơn sales
    // Header hiển thị trên modal
    public class SaleDetailHeaderDto
    {
        public int SaleID { get; set; }
        public string InvoiceNo { get; set; }
        public DateTime SaleDate { get; set; }

        public int? CustomerID { get; set; }
        public string CustomerName { get; set; }
        public string CustomerPhone { get; set; }

        public int UserID { get; set; }
        public string CashierName { get; set; }

        public string PaymentStatus { get; set; }
        public string PaymentMethod { get; set; }
    }

    // Chi tiết từng dòng hàng
    public class SaleItemDetailDto
    {
        public int SaleID { get; set; }
        public int ProductID { get; set; }
        public string ProductName { get; set; }
        public string SKU { get; set; }

        public int Quantity { get; set; }
        public decimal UnitPrice { get; set; }
        public decimal Discount { get; set; }   // % giảm
        public decimal VatPercent { get; set; } // % VAT
        public decimal LineTotal { get; set; }  // Thành tiền sau giảm + VAT (nếu em muốn)
    }

    // Tổng tiền cho modal
    public class SaleTotalsDto
    {
        public decimal Subtotal { get; set; }      // tổng sau discount, chưa VAT
        public decimal VatPercent { get; set; }    // %
        public decimal VatAmount { get; set; }     // tiền VAT
        public decimal Total { get; set; }         // tổng cuối cùng
        public decimal CustomerPaid { get; set; }  // khách đã trả
    }

    public class SaleDetailDto
    {
        public SaleDetailHeaderDto Sale { get; set; }
        public List<SaleItemDetailDto> Items { get; set; }
        public SaleTotalsDto Totals { get; set; }
    }
}
