using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Model;

namespace DAL.Interfaces
{
    public interface ISalesRepository
    {
        SalesModel GetDatabyID(int id);
        bool Create(SalesModel model);
        bool Update(SalesModel model);
        bool Delete(SalesModel model);
    }
}
