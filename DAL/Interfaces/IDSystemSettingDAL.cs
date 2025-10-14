// File: DAL/Interfaces/ISystemDAL.cs
using Model;
using System.Collections.Generic;

namespace DAL.Interfaces
{
    public interface ISystemDAL
    {
        bool Create(SystemSettingModel model);
        bool Delete(int id);
        bool Update(SystemSettingModel model);
        SystemSettingModel GetDatabyID(int systemId);
        List<SystemSettingModel> Search(SystemSettingSearchRequest request, out long total);
    }
}