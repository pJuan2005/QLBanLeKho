using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Model;
using DAL.Interfaces;
using DAL.Helper;
using BLL.Interfaces;
using DAL;

namespace BLL
{
    public class InvoiceBusiness : IInvoiceBusiness
    {
        private IInvoiceRepository _res;
        public InvoiceBusiness(IInvoiceRepository res)
        {
            _res = res;
        }

        public InvoiceModel GetDatabyID(int id)
        {
            return _res.GetDatabyID(id);
        }
        public bool Create(InvoiceModel model)
        {
            return _res.Create(model);
        }
      
        public bool Delete(InvoiceModel model)
        {
            return _res.Delete(model);
        }
    }
}
