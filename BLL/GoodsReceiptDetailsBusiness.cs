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

        public List<GoodsReceiptDetailsModel> GetDatabyID(int id)
        {
            return _res.GetDatabyID(id);
        }



        public bool CreateMultiple(List<GoodsReceiptDetailsModel> models)
        {
            return _res.CreateMultiple(models);
        }
        
        public bool Delete(GoodsReceiptDetailsModel model)
        {
            return _res.Delete(model);
        }
    }
}
