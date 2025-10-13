using Model;
using DAL;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BLL.Interfaces
{
    public interface IArCustomerBusiness
    {
        List<ArCustomerModel.ListAr> Search(int pageIndex, int pageSize, out long total, string search);
        ArCustomerModel.DetailAr GetDetail(int id);
        ArCustomerModel.CheckLimitResult CheckLimit(int id, decimal newAmount, decimal prepay =0);
    }
}
