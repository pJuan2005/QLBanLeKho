using Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BLL
{
    public interface ICategoryBusiness
    {
        CategoryModel GetDatabyID(int id);
        bool Create(CategoryModel model);
        bool Update(CategoryModel model);
        bool Delete(int id);
        List<CategoryModel> Search(int pageIndex, int pageSize, out long total, int? categoryId, string categoryName, string option);
    }
}
