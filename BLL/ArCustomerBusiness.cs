using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Model;
using DAL;
using BLL.Interfaces;
using DAL.Interfaces;

namespace BLL
{
    public class ArCustomerBusiness:IArCustomerBusiness
    {
        private readonly IArCustomerRepository _repo;
        public ArCustomerBusiness(IArCustomerRepository repo)
        {
            _repo = repo;
        }

        public List<ArCustomerModel.ListAr> Search(int pageIndex, int pageSize, out long total, string search)
        {
            return _repo.Search(pageIndex, pageSize, out total, search);
        }

        public ArCustomerModel.DetailAr GetDetail(int customerId)
        {
            return _repo.GetDetail(customerId);
        }

        public ArCustomerModel.CheckLimitResult CheckLimit(int customerId, decimal newAmount, decimal prepay = 0)
        {
            // lấy hạn mức & nợ hiện tại
            var limit = _repo.GetDebtLimit(customerId);
            var current = _repo.GetCurrentDebt(customerId);

            // tính phần nợ phát sinh thực sự từ đơn mới (đã trừ tiền trả trước)
            var effective = Math.Max(0, newAmount - prepay);
            var projected = current + effective;

            var ok = projected <= limit;
            var overBy = ok ? 0 : (projected - limit);

            return new ArCustomerModel.CheckLimitResult
            {
                Ok = ok,
                CustomerID = customerId,
                DebtLimit = limit,
                CurrentDebt = current,
                NewAmount = newAmount,
                Prepay = prepay,
                ProjectedDebt = projected,
                OverBy = overBy,
                Message = ok ? "Trong hạn mức" : $"Vượt hạn mức {overBy:N0}đ"
            };
        }
    }
}
