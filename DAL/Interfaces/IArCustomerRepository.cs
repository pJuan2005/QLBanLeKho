using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Model;

namespace DAL.Interfaces
{
    
    public interface IArCustomerRepository
    {
        List<ArCustomerModel.ListAr> Search(int pageIndex, int pageSize, out long total, string search);
        ArCustomerModel.DetailAr GetDetail(int id);
        decimal GetDebtLimit(int id);
        decimal GetCurrentDebt(int id);
    }
}
