using Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BLL.Interfaces
{
    public interface IDSanPhamBLL
    {
        // Lấy sản phẩm theo ID
        SanPhamModel GetDatabyID(int id);

        // Thêm mới sản phẩm
        bool Create(SanPhamModel model);

        // Cập nhật sản phẩm
        bool Update(SanPhamModel model);

        // Xóa sản phẩm
        bool Delete(int id);

        // Tìm kiếm & phân trang
        List<SanPhamModel> Search(int pageIndex, int pageSize, out long total,
                                  int? MaSanPham, string TenSanPham, string option);
    }
}
