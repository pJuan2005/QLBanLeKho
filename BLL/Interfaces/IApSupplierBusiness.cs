using Model;
using DAL;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BLL.Interfaces
{
    public interface IApSupplierBusiness
    {
        List<ApSupplierModel.ListAp> Search(int pageIndex, int pageSize, out long total, string search);
        ApSupplierModel.DetailAp GetdataById(int id);
    }
}
