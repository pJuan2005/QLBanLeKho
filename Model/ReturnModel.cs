using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model
{
    public class ReturnModel
    {
        public int ReturnID { get; set; }          // Mã phiếu trả hàng
        public int? SaleID { get; set; }            // Mã đơn bán hàng
        public int? CustomerID { get; set; }        // Mã khách hàng
        public int? ReceiptID { get; set; }            // Mã đơn bán hàng
        public int? SupplierID { get; set; }        // Mã khách hàng
        public DateTime ReturnDate { get; set; }   // Ngày trả hàng
        public string Reason { get; set; }         // Lý do trả

    }



    public class ReturnCustomerModel
    {
        public int ReturnID { get; set; }          // Mã phiếu trả hàng
        public int? SaleID { get; set; }            // Mã đơn bán hàng
        public int? CustomerID { get; set; }        // Mã khách hàng
        public DateTime ReturnDate { get; set; }   // Ngày trả hàng
        public string Reason { get; set; }         // Lý do trả

    }



    public class ReturnSupplierModel
    {
        public int ReturnID { get; set; }          // Mã phiếu trả hàng
        public int? ReceiptID { get; set; }            // Mã đơn bán hàng
        public int? SupplierID { get; set; }        // Mã khách hàng
        public DateTime ReturnDate { get; set; }   // Ngày trả hàng
        public string Reason { get; set; }         // Lý do trả

    }

    public class ReturnSearchRequest
    {
        public int page { get; set; }
        public int pageSize { get; set; }
        public int? ReturnID { get; set; }
        public int? SaleID { get; set; }
        public int? CustomerID { get; set; }
        public int? ReceiptID { get; set; }            // Mã đơn bán hàng
        public int? SupplierID { get; set; }        // Mã khách hàng
        public DateTime? FromDate { get; set; }
        public DateTime? ToDate { get; set; }
    }
}
