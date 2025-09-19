using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Model;

namespace BLL.Interfaces
{
    public interface IDonMuaHangBusiness
    {
        DonMuaHangModel GetDatabyID(int id);
        bool Create(DonMuaHangModel model);
        bool Update(DonMuaHangModel model);
        bool Delete(DonMuaHangModel model);
        List<DonMuaHangModel> Search(int pageIndex, int pageSize, out long total, int POID, DateTime OrderDate, decimal TotalAmount);
    }
}
