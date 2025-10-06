using BLL.Interfaces;
using DAL.Interfaces;
using Model;
using System.Collections.Generic;

namespace BLL
{
    public class SystemSettingBLL : IDSystemSettingBLL
    {
        private readonly IDSystemSettingDAL _res;

        public SystemSettingBLL(IDSystemSettingDAL res)
        {
            _res = res;
        }

        public SystemSettingModel GetDatabyKey(string key)
        {
            return _res.GetDatabyKey(key);
        }

        public bool Create(SystemSettingModel model)
        {
            return _res.Create(model);
        }

        public bool Update(SystemSettingModel model)
        {
            return _res.Update(model);
        }

        public bool Delete(int id)
        {
            return _res.Delete(id);
        }

        public List<SystemSettingModel> Search(int pageIndex, int pageSize, out long total, string SettingKey, string Description, string option)
        {
            return _res.Search(pageIndex, pageSize, out total, SettingKey, Description, option);
        }
    }
}
