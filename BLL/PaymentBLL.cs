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

        // ✅ Lấy dữ liệu theo ID
        public PaymentModel GetDatabyID(int id)
        {
            return _res.GetDatabyID(id);
        }

        // ✅ Thêm mới thanh toán
        public bool Create(PaymentModel model)
        {
            return _res.Create(model);
        }

        // ✅ Cập nhật thanh toán
        public bool Update(PaymentModel model)
        {
            return _res.Update(model);
        }

        // ✅ Xoá thanh toán
        public bool Delete(int id)
        {
            return _res.Delete(id);
        }

        // ✅ Tìm kiếm & phân trang
        public List<PaymentModel> Search(int pageIndex, int pageSize, out long total,
                                         int? paymentId, int? customerId, int? supplierId,
                                         string method, string option)
        {
            return _res.Search(pageIndex, pageSize, out total,
                               paymentId, customerId, supplierId,
                                method, option);
        }
    }
}
