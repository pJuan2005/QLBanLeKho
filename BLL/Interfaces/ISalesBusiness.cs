using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Model;

namespace BLL.Interfaces
{
    public interface ISalesBusiness
    {
        SalesModel GetDatabyID(int id);
        bool Create(SalesModel model);
        bool Update(SalesModel model);
        bool Delete(SalesModel model);
    }
}
