using Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAL.Interfaces
{
    public partial interface IDonMuaHangRepository
    {
        DonMuaHangModel GetDatabyID(int id);
        bool Create(DonMuaHangModel model);
        bool Update(DonMuaHangModel model);
        bool Delete(DonMuaHangModel model);
        List<DonMuaHangModel> Search(int pageIndex, int pageSize, out long total, int SupplierID, DateTime OrderDate, decimal TotalAmount);
    }
}
