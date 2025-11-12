using Model;
using System.Collections.Generic;

namespace BLL.Interfaces
{

    // BLL.Interfaces
    public interface IDPaymentBLL
    {
        PaymentModel GetByID(int paymentId);
        bool CreateSupplier(PaymentSupplierModel model);
        bool CreateCustomer(PaymentCustomerModel model);
        bool Update(PaymentModel model);
        bool Delete(int paymentId);
        List<PaymentModel> Search(int pageIndex, int pageSize, out long total,
                                  int? CustomerID, int? SupplierID, int? SaleID, int? ReceiptID, string Method,
                                  DateTime? FromDate, DateTime? ToDate);
    }
}
