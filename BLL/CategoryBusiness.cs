using BLL.Interfaces;
using DAL;
using Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BLL
{
    public class CategoryBusiness:ICategoryBusiness
    {
        private ICategoryRepository  _res;
        public CategoryBusiness(ICategoryRepository res)
        {
            _res = res;
        }

        public CategoryModel GetDatabyID(int id)
        {
             return _res.GetDatabyID(id);
        }

        public bool Create(CategoryModel model)
        {
            return _res.Create(model);
        }

        public bool Update(CategoryModel model)
        {
            return _res.Update(model);
        }
        public bool Delete(int id)
        {
            return _res.Delete(id);
        }
        public List<CategoryModel> Search(int pageIndex, int pageSize, out long total, int? categoryId, string categoryName, string option)
        {
            return _res.Search(pageIndex,pageSize,out total,categoryId,categoryName,option);
        }

        // Overload mới có thêm bộ lọc VAT
        public List<CategoryModel> Search(
            int pageIndex,
            int pageSize,
            out long total,
            int? categoryId,
            string categoryName,
            string option,
            decimal? vatExact,
            decimal? vatFrom,
            decimal? vatTo
        )
        {
            // Nếu repo chưa có overload riêng cho VAT, bạn có thể viết tạm redirect về cùng SP.
            return _res.Search(pageIndex, pageSize, out total, categoryId, categoryName, option, vatExact, vatFrom, vatTo);
        }
    }
}
