using Model;
using System.Collections.Generic;

namespace DAL.Interfaces
{
    // DAL.Interfaces
    public partial interface IDPaymentDAL
    {
        PaymentModel GetByID(int paymentId);
        bool CreateCustomer(PaymentCustomerModel model);
        bool CreateSupplier(PaymentSupplierModel model);
        bool Update(PaymentModel model);
        bool Delete(int paymentId);
        List<PaymentModel> Search(int pageIndex, int pageSize, out long total,
                                  int? CustomerID, int? SupplierID, int? SaleID, int? ReceiptID, string Method,
                                  DateTime? FromDate, DateTime? ToDate);
        List<ArOpenInvoiceDto> GetArOpenInvoices(int pageIndex, int pageSize, out long total,
                                                 string search, DateTime? fromDate, DateTime? toDate);

        List<ApOpenBillDto> GetApOpenBills(int pageIndex, int pageSize, out long total,
                                           string search, DateTime? fromDate, DateTime? toDate);
    }
}
