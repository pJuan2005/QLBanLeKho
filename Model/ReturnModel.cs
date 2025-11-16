using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model
{
    public class ReturnModel
    {
        public int ReturnID { get; set; }
        public byte? ReturnType { get; set; } // 1 = customer, 2 = supplier
        public int? SaleID { get; set; }
        public int? ReceiptID { get; set; }
        public int? CustomerID { get; set; }
        public int? SupplierID { get; set; }
        public string? PartnerName { get; set; }
        public string? PartnerPhone { get; set; }
        public int? ProductID { get; set; }
        public string? ProductName { get; set; }
        public int? Quantity { get; set; }
        public decimal UnitPrice { get; set; }
        public DateTime ReturnDate { get; set; }
        public string? Reason { get; set; }
    }




    public class ReturnUpdateRequest
    {
        public int ReturnID { get; set; }
        public byte? ReturnType { get; set; }
        public int? SaleID { get; set; }
        public int? ReceiptID { get; set; }
        public string? PartnerPhone { get; set; }
        public int? ProductID { get; set; }
        public int? Quantity { get; set; }
        public DateTime? ReturnDate { get; set; }
        public string? Reason { get; set; }
    }



    public class ReturnCreateRequest
    {
        public byte ReturnType { get; set; }
        public string PartnerPhone { get; set; }
        public int? SaleID { get; set; }
        public int? ReceiptID { get; set; }
        public int? ProductID { get; set; }
        public int? Quantity { get; set; }
        public DateTime ReturnDate { get; set; }
        public string? Reason { get; set; }
    }


    public class ReturnSearchRequest
    {
        public int page { get; set; }
        public int pageSize { get; set; }
        public int? ReturnID { get; set; }
        public byte? ReturnType { get; set; }
        public int? SaleID { get; set; }
        public int? ReceiptID { get; set; }
        public int? CustomerID { get; set; }
        public int? SupplierID { get; set; }
        public string? PartnerName { get; set; }
        public string? PartnerPhone { get; set; }
        public int? ProductID { get; set; }
        public DateTime? FromDate { get; set; }
        public DateTime? ToDate { get; set; }
    }
}
