using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Model;

namespace DAL.Interfaces
{
    public interface IDPaymentDAL
    {
        // ✅ Lấy thanh toán theo ID
        PaymentModel GetDatabyID(int paymentId);

        // ✅ Thêm thanh toán
        bool Create(PaymentModel model);

        // ✅ Cập nhật thanh toán
        bool Update(PaymentModel model);

        // ✅ Xóa thanh toán
        bool Delete(int paymentId);

        // ✅ Tìm kiếm thanh toán (có phân trang)
        List<PaymentModel> Search(int pageIndex, int pageSize, out long total,
                                  int? PaymentID, int? CustomerID, int? SupplierID,
                                  DateTime? FromDate, DateTime? ToDate,
                                  string Method, string option);
    }
}
