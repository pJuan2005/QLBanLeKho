using BLL.Interfaces;
using DAL;
using DAL.Interfaces;
using Model;
using System;
using System.Collections.Generic;

namespace BLL
{
    public class PaymentBLL : IDPaymentBLL
    {
        private readonly IDPaymentDAL _res;

        public PaymentBLL(IDPaymentDAL res)
        {
            _res = res;
        }

        public PaymentModel GetByID(int id)
        {
            return _res.GetByID(id);
        }

        public bool CreateCustomer(PaymentCustomerModel model)
        {
            return _res.CreateCustomer(model);
        }
        public bool CreateSupplier(PaymentSupplierModel model)
        {
            return _res.CreateSupplier(model);
        }

        public bool Update(PaymentModel model)
        {
            return _res.Update(model);
        }

        public bool Delete(int id)
        {
            return _res.Delete(id);
        }
        public List<PaymentModel> Search(int pageIndex, int pageSize, out long total,
                                 int? CustomerID, int? SupplierID, int? SaleID, int? ReceiptID, string Method,
                                 DateTime? FromDate, DateTime? ToDate)
        {
            return _res.Search(pageIndex, pageSize, out total,
                               CustomerID, SupplierID, SaleID, ReceiptID, Method, FromDate, ToDate);
        }

        public List<ArOpenInvoiceDto> GetArOpenInvoices(
            int pageIndex, int pageSize, out long total,
            string search, DateTime? fromDate, DateTime? toDate)
        {
            return _res.GetArOpenInvoices(pageIndex, pageSize, out total, search, fromDate, toDate);
        }

        public List<ApOpenBillDto> GetApOpenBills(
            int pageIndex, int pageSize, out long total,
            string search, DateTime? fromDate, DateTime? toDate)
        {
            return _res.GetApOpenBills(pageIndex, pageSize, out total, search, fromDate, toDate);
        }

    }
}
