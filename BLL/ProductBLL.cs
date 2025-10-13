using BLL.Interfaces;
using DAL.Interfaces;
using Model;
using System;
using System.Collections.Generic;

namespace BLL
{
    public class ProductBLL : IDProductBLL
    {
        private readonly IDProductDAL _res;

        public ProductBLL(IDProductDAL res)
        {
            _res = res;
        }

        public ProductModel GetDatabyID(int id)
        {
            return _res.GetDatabyID(id);
        }

        public bool Create(ProductModel model)
        {
            return _res.Create(model);
        }

        public bool Update(ProductModel model)
        {
            return _res.Update(model);
        }

        public bool Delete(int id)
        {
            return _res.Delete(id);
        }

        public List<ProductModel> Search(ProductSearchRequest request, out long total)
        {
            return _res.Search(request, out total);
        }
    }
}
