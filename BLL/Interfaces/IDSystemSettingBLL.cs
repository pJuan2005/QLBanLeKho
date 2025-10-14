// File: BLL/Interfaces/ISystemBLL.cs
using Model;
using System.Collections.Generic;

namespace BLL.Interfaces
{
    public interface ISystemBLL
    {
        bool Create(SystemSettingModel model);
        bool Delete(int id);
        bool Update(SystemSettingModel model);
        SystemSettingModel GetDatabyID(int systemId);
        List<SystemSettingModel> Search(SystemSettingSearchRequest request, out long total);
    }
}