using System;

namespace Model
{
    public class PaymentModel
    {
        public int PaymentID { get; set; }        // Mã thanh toán (khóa chính)
        public int? CustomerID { get; set; }      // Mã khách hàng
        public int? SupplierID { get; set; }
        public int? SaleID { get; set; }      // Mã đơn hàng
        public int? ReceiptID { get; set; }      // Mã đơn hàng
        public decimal Amount { get; set; }       // Số tiền
        public DateTime PaymentDate { get; set; } // Ngày thanh toán
        public string Method { get; set; }        // Hình thức thanh toán (Tiền mặt, Chuyển khoản,...)
        public string Description { get; set; }          // Ghi chú (tuỳ chọn)
    }


    public class PaymentCustomerModel
    {
        public int PaymentID { get; set; }        // Mã thanh toán (khóa chính)
        public int? CustomerID { get; set; }      // Mã khách hàng
        public int? SaleID { get; set; }      // Mã đơn hàng
        public decimal Amount { get; set; }       // Số tiền
        public DateTime PaymentDate { get; set; } // Ngày thanh toán
        public string Method { get; set; }        // Hình thức thanh toán (Tiền mặt, Chuyển khoản,...)
        public string Description { get; set; }          // Ghi chú (tuỳ chọn)
    }


    public class PaymentSupplierModel
    {
        public int PaymentID { get; set; }        // Mã thanh toán (khóa chính)
        public int? SupplierID { get; set; }      // Mã khách hàng
        public int? ReceiptID { get; set; }      // Mã đơn hàng
        public decimal Amount { get; set; }       // Số tiền
        public DateTime PaymentDate { get; set; } // Ngày thanh toán
        public string Method { get; set; }        // Hình thức thanh toán (Tiền mặt, Chuyển khoản,...)
        public string Description { get; set; }          // Ghi chú (tuỳ chọn)
    }

    public class PaymentSearchRequest
    {
        public int page { get; set; }
        public int pageSize { get; set; }
        public int? CustomerID { get; set; }
        public int? SupplierID { get; set; }
        public int? SaleID { get; set; }
        public int? ReceiptID { get; set; }      
        public string Method { get; set; }
        public DateTime? FromDate { get; set; }
        public DateTime? ToDate { get; set; }
    }
}
