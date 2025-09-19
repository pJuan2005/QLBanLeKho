using BLL.Interfaces;
using DAL;
using DAL.Interfaces;
using Model;
using System.Collections.Generic;

namespace BLL
{
    public class ProductBLL : IDProductBLL
    {
        private readonly IDProductDAL _res;

        public ProductBLL(IDProductDAL res)
        {
            _res = res;
        }

        // Lấy dữ liệu theo ID
        public ProductModel GetDatabyID(int id)
        {
            return _res.GetDatabyID(id);
        }

        // Thêm mới sản phẩm
        public bool Create(ProductModel model)
        {
            return _res.Create(model);
        }

        // Cập nhật sản phẩm
        public bool Update(ProductModel model)
        {
            return _res.Update(model);
        }

        // Xoá sản phẩm
        public bool Delete(int id)
        {
            return _res.Delete(id);
        }

        // Tìm kiếm & phân trang
        public List<ProductModel> Search(int pageIndex, int pageSize, out long total,
                                 int? productId, string productName, string option)
        {
            return _res.Search(pageIndex, pageSize, out total, productId, null, productName, null, null, option);
        }
    }
    
}
