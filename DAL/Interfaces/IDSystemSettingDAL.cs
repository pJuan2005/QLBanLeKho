using Model;

namespace DAL.Interfaces
{
    public partial interface IDSettingsDAL
    {
        SettingsModel GetSettings();
        bool UpdateSettings(SettingsModel model);
    }
}
