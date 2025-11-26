using DAL.Interfaces;
using DAL.Helper;
using Model;
using System;
using System.Linq;

namespace DAL
{
    public class SettingsDAL : IDSettingsDAL
    {
        private readonly IDatabaseHelper _dbHelper;

        public SettingsDAL(IDatabaseHelper dbHelper)
        {
            _dbHelper = dbHelper;
        }

        public SettingsModel GetSettings()
        {
            string msgError = "";
            var dt = _dbHelper.ExecuteSProcedureReturnDataTable(
                out msgError, "sp_settings_get");

            if (!string.IsNullOrEmpty(msgError))
                throw new Exception(msgError);

            return dt.ConvertTo<SettingsModel>().FirstOrDefault();
        }

        public bool UpdateSettings(SettingsModel model)
        {
            string msgError = "";

            _dbHelper.ExecuteScalarSProcedureWithTransaction(
                out msgError,
                "sp_settings_update",
                "@SettingID", model.SettingID,
                "@VATRate", model.VATRate,
                "@DefaultLanguage", model.DefaultLanguage
            );

            if (!string.IsNullOrEmpty(msgError))
                throw new Exception(msgError);

            return true;
        }
    }
}
