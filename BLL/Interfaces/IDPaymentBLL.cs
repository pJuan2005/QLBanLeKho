using Model;
using System;
using System.Collections.Generic;

namespace BLL.Interfaces
{
    public interface IDPaymentBLL
    {
        // ✅ Lấy thanh toán theo ID
        PaymentModel GetDatabyID(int id);

        // ✅ Thêm mới thanh toán
        bool Create(PaymentModel model);

        // ✅ Cập nhật thanh toán
        bool Update(PaymentModel model);

        // ✅ Xóa thanh toán
        bool Delete(int id);

        // ✅ Tìm kiếm & phân trang
        List<PaymentModel> Search(int pageIndex, int pageSize, out long total,
                                  int? PaymentID, int? CustomerID, int? SupplierID,
                                  string Method, string option);
    }
}

