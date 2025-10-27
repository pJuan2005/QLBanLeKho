using Model;
using System.Collections.Generic;

namespace DAL.Interfaces
{
    public partial interface IDPaymentDAL
    {
        PaymentModel GetByID(int paymentId);
        bool CreateCustomer(PaymentCustomerModel model);
        bool CreateSupplier(PaymentSupplierModel model);
        bool Update(PaymentModel model);
        bool Delete(int paymentId);
        List<PaymentModel> Search(int pageIndex, int pageSize, out long total,
                                  int? CustomerID,int? SupplierID,int? ReceiptID, int? SaleID, string Method,
                                  DateTime? FromDate, DateTime? ToDate);
    }
}
