using Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BLL.Interfaces
{
    public interface IDProductBLL
    {
        // Lấy sản phẩm theo ID
        ProductModel GetDatabyID(int id);

        // Thêm mới sản phẩm
        bool Create(ProductModel model);

        // Cập nhật sản phẩm
        bool Update(ProductModel model);

        // Xóa sản phẩm
        bool Delete(int id);

        // Tìm kiếm & phân trang
        List<ProductModel> Search(int pageIndex, int pageSize, out long total,
                                  int? MaSanPham, string TenSanPham, string option);
    }
}
