using Model;
using System.Collections.Generic;

namespace BLL.Interfaces
{
    public interface IDSystemSettingBLL
    {
        SystemSettingModel GetDatabyKey(string key);
        bool Create(SystemSettingModel model);
        bool Update(SystemSettingModel model);
        bool Delete(int id);
        List<SystemSettingModel> Search(int pageIndex, int pageSize, out long total, string SettingKey, string Description, string option);
    }
}
