using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Model;

namespace DAL.Interfaces
{
    public interface IInvoiceRepository
    {
        InvoiceModel GetDatabyID(int id);
        bool Create(InvoiceModel model);
       
        bool Delete(InvoiceModel model);
    }
}
