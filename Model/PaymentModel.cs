using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model
{
    public class PaymentModel
    {
        public int PaymentID { get; set; }        // Mã thanh toán (khóa chính)
        public int? CustomerID { get; set; }      // Mã khách hàng (nullable vì có thể thanh toán cho nhà cung cấp)
        public int? SupplierID { get; set; }      // Mã nhà cung cấp (nullable vì có thể thanh toán cho khách hàng)
        public decimal Amount { get; set; }       // Số tiền thanh toán
        public DateTime PaymentDate { get; set; } // Ngày thanh toán
        public string Method { get; set; }
    }
}
