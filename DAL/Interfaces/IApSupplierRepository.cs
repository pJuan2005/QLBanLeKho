using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Model;

namespace DAL.Interfaces
{
    public interface IApSupplierRepository
    {
        List<ApSupplierModel.ListAp> Search(int pageIndex, int pageSize, out long total, string search);
        ApSupplierModel.DetailAp GetdataById(int id);

    }
}
