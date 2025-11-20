using BLL.Interfaces;
using DAL.Interfaces;
using Model;

namespace BLL
{
    public class SettingsBLL : IDSettingsBLL
    {
        private readonly IDSettingsDAL _settingsDAL;

        public SettingsBLL(IDSettingsDAL settingsDAL)
        {
            _settingsDAL = settingsDAL;
        }

        public SettingsModel GetSettings()
        {
            return _settingsDAL.GetSettings();
        }

        public bool UpdateSettings(SettingsModel model)
        {
            return _settingsDAL.UpdateSettings(model);
        }
    }
}
