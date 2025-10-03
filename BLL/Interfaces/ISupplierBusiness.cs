using DAL;
using Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BLL
{
    public interface ISupplierBusiness
    {
        SupplierModel GetdataByID(int id);
        bool Create(SupplierModel model);
        bool Update(SupplierModel model);
        bool Delete(int id);
        List<SupplierModel> Search(int pageIndex, int pageSize, out long total, string Phone);
    }
}
