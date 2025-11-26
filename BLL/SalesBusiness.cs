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

            // ==========================================================
            // 1) LẤY ORDER TOTAL TỪ FE (ĐÃ BAO GỒM DISCOUNT + VAT)
            // ==========================================================
            var orderTotal = dto.ClientTotal;

            // Trường hợp xấu: FE không gửi hoặc gửi 0 → fallback tính sơ bộ
            if (orderTotal <= 0)
            {
                decimal subTotal = 0;
                foreach (var item in dto.Items)
                {
                    if (item.Quantity <= 0)
                        throw new Exception("Số lượng sản phẩm không hợp lệ.");

                    // Tạm tính theo discount FE gửi (chỉ là backup)
                    var baseLine = item.UnitPrice * item.Quantity;
                    var afterDiscount = baseLine * (1 - item.Discount / 100m);
                    subTotal += afterDiscount;
                }

                // Fallback: nếu không có ClientTotal thì coi subtotal này là tổng
                orderTotal = subTotal;
            }

            // ==========================================================
            // 2) TIỀN KHÁCH TRẢ & TIỀN THỪA
            // ==========================================================
            var rawPay = dto.Prepay;
            if (rawPay < 0) rawPay = 0;

            // Tiền thực sự áp dụng cho đơn này (không bao giờ > orderTotal)
            var appliedPay = Math.Min(rawPay, orderTotal);

            // Tiền thừa (nếu có) – hiện anh chưa dùng, nhưng để đây sau FE/BE dùng cũng được
            var changeToReturn = Math.Max(0, rawPay - orderTotal);

            // ==========================================================
            // 3) KIỂM TRA CÔNG NỢ
            // ==========================================================
            var beforeDebt = _arRepo.GetCurrentDebt(dto.CustomerId);
            var limit = _arRepo.GetDebtLimit(dto.CustomerId);

            // Phần còn thiếu của ORDER TOTAL trở thành nợ
            var debtIncrease = orderTotal - appliedPay;
            if (debtIncrease < 0) debtIncrease = 0; // phòng hờ, nhưng về lý thuyết = 0 hoặc >0

            var projected = beforeDebt + debtIncrease;

            if (limit > 0 && projected > limit)
                throw new Exception("Vượt hạn mức công nợ của khách hàng.");

            // ==========================================================
            // 4) TẠO SALES HEADER
            // ==========================================================
            var saleHeader = new SalesModel
            {
                CustomerID = dto.CustomerId,
                UserID = dto.UserId,
                SaleDate = DateTime.Now,
                PaymentStatus = appliedPay >= orderTotal ? "Paid" : "Unpaid"
            };

            int saleId = _salesRepo.CreateReturnId(saleHeader);

            // ==========================================================
            // 5) TẠO SALES ITEMS (DB TRIGGER SẼ TỰ GÁN DISCOUNT + TÍNH TOTAL)
            // ==========================================================
            foreach (var item in dto.Items)
                item.SaleID = saleId;

            var ok = _salesItemRepo.CreateMultiple(dto.Items);
            if (!ok)
                throw new Exception("Không thể tạo chi tiết sản phẩm cho đơn hàng.");

            // ==========================================================
            // 6) TẠO PAYMENT – LƯU ĐÚNG SỐ TIỀN ĐÃ ÁP DỤNG (appliedPay)
            // ==========================================================
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

            // ==========================================================
            // 7) LẤY LẠI ĐƠN & NỢ MỚI
            //    (lúc này trigger đã chạy → Sales.TotalAmount, VATAmount đã chuẩn)
            // ==========================================================
            var savedSale = _salesRepo.GetDatabyID(saleId);
            var afterDebt = beforeDebt + debtIncrease;

            return new PosSaleResult
            {
                Sale = savedSale,
                BeforeDebt = beforeDebt,
                NewRemainingDebt = afterDebt
                // ChangeToReturn có thể thêm vào DTO nếu em cần
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

        public List<SalesListItemDto> SearchList(
    int pageIndex, int pageSize, out long total,
    string status, DateTime? fromDate, DateTime? toDate,
    string keyword)
        {
            return _salesRepo.SearchList(pageIndex, pageSize, out total,
                status, fromDate, toDate, keyword);
        }


        public List<SalesModel> Search(int pageIndex, int pageSize, out long total,
            decimal? minTotalAmount, decimal? maxTotalAmount,
            string status, DateTime? fromDate, DateTime? toDate)
        {
            return _salesRepo.Search(pageIndex, pageSize, out total,
                minTotalAmount, maxTotalAmount, status, fromDate, toDate);
        }

        public SalesDashboardDto GetDashboard(decimal? minTotalAmount, decimal? maxTotalAmount,string status, DateTime? fromDate, DateTime? toDate,string keyword)
        {
            return _salesRepo.GetDashboard( minTotalAmount, maxTotalAmount,
                status, fromDate, toDate, keyword);
        }

        public SaleDetailDto GetDetail(int saleId)
        {
            return _salesRepo.GetDetail(saleId);
        }

    }
}
