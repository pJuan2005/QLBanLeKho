using Model;

namespace BLL.Interfaces
{
    public interface IDSettingsBLL
    {
        SettingsModel GetSettings();
        bool UpdateSettings(SettingsModel model);
    }
}
