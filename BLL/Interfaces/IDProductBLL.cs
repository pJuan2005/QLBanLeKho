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
        ProductModel GetDatabyID(int productId);
        bool Create(ProductModel model);
        bool Update(ProductModel model);
        bool Delete(int productId);
        List<ProductModel> Search(int pageIndex, int pageSize, out long total,
                                  int? ProductID, string SKU, string ProductName,
                                  int? CategoryID, int? SupplierID);



    }
}
