using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Model;

namespace BLL.Interfaces
{
    public interface IInvoiceBusiness
    {
        InvoiceModel GetDatabyID(int id);
        bool Create(InvoiceModel model);
        
        bool Delete(InvoiceModel model);
    }
}
