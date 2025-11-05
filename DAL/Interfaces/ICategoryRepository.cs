using Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAL
{
    public interface ICategoryRepository
    {
        CategoryModel GetDatabyID(int id);
        bool Create(CategoryModel model);
        bool Update(CategoryModel model);
        bool Delete(int id);
        List<CategoryModel> Search(int pageIndex, int pageSize,out long total,int? categoryId,string categoryName,string option);
        // Overload mới: thêm lọc VAT (exact hoặc khoảng)
        List<CategoryModel> Search(
            int pageIndex,
            int pageSize,
            out long total,
            int? categoryId,
            string categoryName,
            string option,
            decimal? vatExact,
            decimal? vatFrom,
            decimal? vatTo
        );
    }
}
