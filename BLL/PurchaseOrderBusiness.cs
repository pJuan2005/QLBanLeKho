using System;
using System.Collections.Generic;
using System.Linq;

using System.Text;
using System.Threading.Tasks;
using BLL.Interfaces;
using DAL;
using DAL.Interfaces;
using Model;

namespace BLL
{
    public class PurchaseOrderBusiness : IPurchaseOrderBusiness
    {
        private IPurchaseOrderRepository _res;
        public PurchaseOrderBusiness(IPurchaseOrderRepository res)
        {
            _res = res;
        }
        public PurchaseOrderModel GetDatabyID(int id)
        {
            return _res.GetDatabyID(id);
        }
        public bool CreateMultiple(List<PurchaseOrderModel> models) // 👈 Thêm phương thức này
        {
            return _res.CreateMultiple(models);
        }
        public bool Update(PurchaseOrderModel model)
        {
            return _res.Update(model);
        }
        public bool Delete(PurchaseOrderModel model)
        {
            return _res.Delete(model);
        }
        public List<PurchaseOrderModel> Search( int pageIndex, int pageSize, out long total, decimal? minTotalAmount, decimal? maxTotalAmount, string status, DateTime? fromDate, DateTime? toDate)
        {
            total = 0;
            try
            {
                // Gọi DAL (đã sửa ở tin nhắn trước – có out total + page_index + page_size)
                return _res.Search(pageIndex, pageSize, out total,
                    minTotalAmount, maxTotalAmount, status, fromDate, toDate);
            }
            catch (Exception ex)
            {
                // Log nếu cần (giống category)
                throw new Exception("Lỗi khi tìm kiếm Purchase Order: " + ex.Message);
            }
        }
    }
}
