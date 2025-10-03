using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography.X509Certificates;
using System.Text;
using System.Threading.Tasks;
using BLL.Interfaces;
using DAL;
using DAL.Interfaces;
using Model;

namespace BLL
{
    public class DonMuaHangBusiness: IDonMuaHangBusiness
    {
        private IDonMuaHangRepository _res;
        public DonMuaHangBusiness(IDonMuaHangRepository res)
        {
            _res = res;
        }
        public DonMuaHangModel GetDatabyID(int id)
        {
            return _res.GetDatabyID(id);
        }
        public bool Create(DonMuaHangModel model)
        {
            return _res.Create(model);
        }
        public bool Update(DonMuaHangModel model)
        {
            return _res.Update(model);
        }
        public bool Delete(DonMuaHangModel model)
        {
            return _res.Delete(model);
        }
        public List<DonMuaHangModel> Search(int pageIndex, int pageSize, out long total, int? SupplierID, DateTime? OrderDate, decimal TotalAmount)
        {
            return _res.Search(pageIndex, pageSize, out total, SupplierID, OrderDate, TotalAmount);
        }
    }
}
