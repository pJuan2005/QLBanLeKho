using Model;
using DAL;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BLL.Interfaces;
using DAL.Interfaces;

namespace BLL
{
    public class ApSupplierBusiness:IApSupplierBusiness
    {
        public IApSupplierRepository _repo;
        public ApSupplierBusiness(IApSupplierRepository repo)
        {
            _repo = repo;
        }

        public List<ApSupplierModel.ListAp> Search(int pageIndex, int pageSize, out long total, string search)
        {
            return _repo.Search(pageIndex, pageSize, out total, search);
        }

        public ApSupplierModel.DetailAp GetdataById(int id)
        {
            return _repo.GetdataById(id);
        }
    }
}
