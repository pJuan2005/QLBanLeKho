using BLL.Interfaces;
using DAL;
using Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BLL
{
    public class CustomerBusiness:ICustomerBusiness
    {
        public ICustomerRepository _customerRepo;
        public CustomerBusiness(ICustomerRepository customerRepo)
        {
            _customerRepo = customerRepo;
        }

        public CustomerModel GetdataById(int id)
        {
            return _customerRepo.GetdataById(id);
        }

        public bool Create(CustomerModel model)
        {
            return _customerRepo.Create(model);
          
        }

        public bool Update(CustomerModel model)
        {
           return _customerRepo.Update(model);
        }

        public bool Delete(int id)
        {
            return _customerRepo.Delete(id);
        }

        public List<CustomerModel> Search(int pageIndex,int pageSize, out long total, string Phone, string Address)
        {
            return _customerRepo.Search(pageIndex, pageSize, out total, Phone, Address);
        }
    }
}
