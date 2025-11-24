using BLL.Interfaces;
using DAL;
using Model;
using Microsoft.Extensions.Caching.Memory;
using System;
using System.Collections.Generic;

namespace BLL
{
    public class CategoryBusiness : ICategoryBusiness
    {
        private readonly ICategoryRepository _res;
        private readonly IMemoryCache _cache;
        private const string CACHE_KEY = "categories_dropdown_cache";

        public CategoryBusiness(ICategoryRepository res, IMemoryCache cache)
        {
            _res = res;
            _cache = cache;
        }

        public CategoryModel GetDatabyID(int id)
        {
            return _res.GetDatabyID(id);
        }

        public bool Create(CategoryModel model)
        {
            var ok = _res.Create(model);
            _cache.Remove(CACHE_KEY);
            return ok;
        }

        public bool Update(CategoryModel model)
        {
            var ok = _res.Update(model);
            _cache.Remove(CACHE_KEY);
            return ok;
        }

        public bool Delete(int id)
        {
            var ok = _res.Delete(id);
            _cache.Remove(CACHE_KEY);
            return ok;
        }

        // Search cũ → gọi sang Search mới
        public List<CategoryModel> Search(int pageIndex, int pageSize, out long total, int? categoryId, string categoryName, string option)
        {
            return Search(pageIndex, pageSize, out total, categoryId, categoryName, option,
                          vatExact: null, vatFrom: null, vatTo: null);
        }

        // Search có VAT + cache dropdown
        public List<CategoryModel> Search(
            int pageIndex,
            int pageSize,
            out long total,
            int? categoryId,
            string categoryName,
            string option,
            decimal? vatExact,
            decimal? vatFrom,
            decimal? vatTo
        )
        {
            bool isDropdownRequest =
                pageIndex == 1 &&
                pageSize >= 1000 &&
                categoryId == null &&
                string.IsNullOrWhiteSpace(categoryName) &&
                string.IsNullOrWhiteSpace(option) &&
                vatExact == null &&
                vatFrom == null &&
                vatTo == null;

            if (isDropdownRequest)
            {
                if (_cache.TryGetValue(CACHE_KEY, out List<CategoryModel> cachedList))
                {
                    total = cachedList.Count;
                    return cachedList;
                }

                var data = _res.Search(pageIndex, pageSize, out total,
                                       categoryId, categoryName, option,
                                       vatExact, vatFrom, vatTo);

                _cache.Set(CACHE_KEY, data,
                    new MemoryCacheEntryOptions
                    {
                        AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(10)
                    });

                return data;
            }

            return _res.Search(pageIndex, pageSize, out total,
                               categoryId, categoryName, option,
                               vatExact, vatFrom, vatTo);
        }
    }
}
