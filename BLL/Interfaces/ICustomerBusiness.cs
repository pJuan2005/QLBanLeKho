using DAL;
using Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BLL
{
    public interface ICustomerBusiness
    {
        CustomerModel GetdataById(int id);
        bool Create(CustomerModel model);
        bool Update(CustomerModel model);
        bool Delete(int id);
        List<CustomerModel> Search(int pageIndex, int pageSize, out long total, string Phone, string Address);
    }
}
