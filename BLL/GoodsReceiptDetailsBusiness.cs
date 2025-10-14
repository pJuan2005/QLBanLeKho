using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Model;
using BLL.Interfaces;
using DAL;
using DAL.Interfaces;

namespace BLL
{
    public class GoodsReceiptDetailsBusiness : IGoodsReceiptDetailsBusiness
    {
        private IGoodsReceiptDetailsRepository _res;
        public GoodsReceiptDetailsBusiness(IGoodsReceiptDetailsRepository res)
        {
            _res = res;
        }

        public GoodsReceiptDetailsModel GetDatabyID(int id)
        {
            return _res.GetDatabyID(id);
        }

        public bool Create(GoodsReceiptDetailsModel model)
        {
            return _res.Create(model);
        }
        public bool Update(GoodsReceiptDetailsModel model)
        {
            return (_res.Update(model));
        }
        public bool Delete(GoodsReceiptDetailsModel model)
        {
            return _res.Delete(model);
        }
    }
}
