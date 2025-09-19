using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Model;

namespace DAL.Interfaces
{
    public partial interface IProductRepository
    {
        // ✅ Lấy sản phẩm theo ID
        SanPhamModel GetDatabyID(int productId);

        // ✅ Thêm sản phẩm
        bool Create(SanPhamModel model);

        // ✅ Cập nhật sản phẩm
        bool Update(SanPhamModel model);

        // ✅ Xóa sản phẩm
        bool Delete(int productId);

        // ✅ Tìm kiếm sản phẩm (có phân trang)
        List<SanPhamModel> Search(int pageIndex, int pageSize, out long total,
                                  int? ProductID, string SKU, string ProductName,
                                  int? CategoryID, int? SupplierID, string option);
    }
}
