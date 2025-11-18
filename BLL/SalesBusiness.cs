using DAL.Interfaces;
using BLL.Interfaces;
using Model;

namespace BLL
{
    public class SalesBusiness : ISalesBusiness
    {
        private readonly ISalesRepository _salesRepo;
        private readonly ISalesItemRepository _salesItemRepo;
        private readonly IDPaymentDAL _paymentDal;
        private readonly IArCustomerRepository _arRepo;

        public SalesBusiness(
            ISalesRepository salesRepo,
            ISalesItemRepository salesItemRepo,
            IDPaymentDAL paymentDal,
            IArCustomerRepository arRepo)
        {
            _salesRepo = salesRepo;
            _salesItemRepo = salesItemRepo;
            _paymentDal = paymentDal;
            _arRepo = arRepo;
        }

        public PosSaleResult CreateFromPos(PosOrderDto dto)
        {
            if (dto == null)
                throw new Exception("Dữ liệu đơn hàng không hợp lệ.");
            if (dto.Items == null || dto.Items.Count == 0)
                throw new Exception("Đơn hàng không có sản phẩm.");

            // 1) TÍNH SUBTOTAL (không VAT – chỉ để backup)
            decimal subTotal = 0;
            foreach (var item in dto.Items)
            {
                if (item.Quantity <= 0)
                    throw new Exception("Số lượng sản phẩm không hợp lệ.");

                var discountPercent = item.Discount; // %
                var baseLine = item.UnitPrice * item.Quantity;
                var afterDiscount = baseLine * (1 - discountPercent / 100m);

                subTotal += afterDiscount;
            }

            // ORDER TOTAL = tổng tiền thực tế (subtotal + VAT) → ưu tiên dùng số FE gửi lên
            var orderTotal = dto.ClientTotal > 0 ? dto.ClientTotal : subTotal;

            // --- TIỀN KHÁCH ĐƯA / ÁP DỤNG / TIỀN THỪA ---
            var rawPay = dto.Prepay;
            if (rawPay < 0) rawPay = 0;

            // DÙNG orderTotal, không dùng subtotal nữa
            var appliedPay = Math.Min(rawPay, orderTotal);         // tiền thực sự dùng để thanh toán đơn này
            var changeToReturn = Math.Max(0, rawPay - orderTotal); // tiền thừa (nếu có)

            // 2) KIỂM TRA CÔNG NỢ
            var beforeDebt = _arRepo.GetCurrentDebt(dto.CustomerId);
            var limit = _arRepo.GetDebtLimit(dto.CustomerId);

            // phần còn thiếu của ORDER TOTAL trở thành nợ
            var debtIncrease = orderTotal - appliedPay;
            var projected = beforeDebt + debtIncrease;

            if (limit > 0 && projected > limit)
                throw new Exception("Vượt hạn mức công nợ của khách hàng.");

            // 3) TẠO SALES HEADER
            var saleHeader = new SalesModel
            {
                CustomerID = dto.CustomerId,
                UserID = dto.UserId,
                SaleDate = DateTime.Now,
                PaymentStatus = appliedPay >= orderTotal ? "Paid" : "Unpaid"
            };

            int saleId = _salesRepo.CreateReturnId(saleHeader);

            // 4) TẠO SALES ITEMS
            foreach (var item in dto.Items)
                item.SaleID = saleId;

            var ok = _salesItemRepo.CreateMultiple(dto.Items);
            if (!ok)
                throw new Exception("Không thể tạo chi tiết sản phẩm cho đơn hàng.");

            // 5) TẠO PAYMENT – LƯU ĐÚNG SỐ TIỀN ĐÃ ÁP DỤNG (theo ORDER TOTAL)
            if (appliedPay > 0)
            {
                var payment = new PaymentCustomerModel
                {
                    CustomerID = dto.CustomerId,
                    SaleID = saleId,
                    Amount = appliedPay,          
                    PaymentDate = dto.PaymentDate,
                    Method = dto.PaymentMethod,
                    Description = "Thanh toán tại POS"
                };

                _paymentDal.CreateCustomer(payment);
            }

            // 6) LẤY LẠI ĐƠN VÀ NỢ MỚI
            var savedSale = _salesRepo.GetDatabyID(saleId);
            var afterDebt = beforeDebt + debtIncrease;

            return new PosSaleResult
            {
                Sale = savedSale,
                BeforeDebt = beforeDebt,
                NewRemainingDebt = afterDebt,
                // ChangeToReturn = changeToReturn (nếu sau này muốn trả về)
            };
        }



        public SalesModel GetDatabyID(int id)
        {
            return _salesRepo.GetDatabyID(id);
        }

        public bool Create(SalesModel model)
        {
            return _salesRepo.Create(model);
        }

        public bool Update(SalesModel model)
        {
            return _salesRepo.Update(model);
        }

        public bool Delete(SalesModel model)
        {
            return _salesRepo.Delete(model);
        }

        public List<SalesModel> Search(int pageIndex, int pageSize, out long total,
            decimal? minTotalAmount, decimal? maxTotalAmount,
            string status, DateTime? fromDate, DateTime? toDate)
        {
            return _salesRepo.Search(pageIndex, pageSize, out total,
                minTotalAmount, maxTotalAmount, status, fromDate, toDate);
        }
    }
}
