using DAL;
using Model;
using BLL.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using DAL.Interfaces;

namespace BLL
{
    public class SupplierBusiness:ISupplierBusiness
    {
        private ISupplierRepository _supplierrepo;
        public SupplierBusiness(ISupplierRepository supplierrepo)
        {
            _supplierrepo = supplierrepo;
        }
        public SupplierModel GetdataByID(int id)
        {
            return _supplierrepo.GetdataByID(id);
        }
        public bool Create(SupplierModel model)
        {
            return _supplierrepo.Create(model);
        }
        public bool Update(SupplierModel model)
        {
            return _supplierrepo.Update(model);
        }
        public bool Delete(int id)
        {
            return _supplierrepo.Delete(id);
        } 
        public List<SupplierModel>Search(int pageIndex, int pageSize, out long total,string phone)
        {
            return _supplierrepo.Search(pageIndex, pageSize, out total, phone);
        }
    }
}
