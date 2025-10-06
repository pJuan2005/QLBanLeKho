using DAL.Interfaces;
using DAL.Helper;
using Model;
using System;
using System.Collections.Generic;
using System.Linq;

namespace DAL
{
    public class SystemSettingDAL : IDSystemSettingDAL
    {
        private readonly IDatabaseHelper _dbHelper;

        public SystemSettingDAL(IDatabaseHelper dbHelper)
        {
            _dbHelper = dbHelper;
        }

        public SystemSettingModel GetDatabyKey(string key)
        {
            string msgError = "";
            try
            {
                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msgError, "sp_systemsetting_get_by_key",
                    "@SettingKey", key);
                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);
                return dt.ConvertTo<SystemSettingModel>().FirstOrDefault();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public bool Create(SystemSettingModel model)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_systemsetting_create",
                    "@SettingKey", model.SettingKey,
                    "@SettingValue", model.SettingValue,
                    "@Description", model.Description,
                    "@UpdatedBy", model.UpdatedBy
                );
                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);
                return true;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public bool Update(SystemSettingModel model)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_systemsetting_update",
                    "@SettingID", model.SettingID,
                    "@SettingValue", model.SettingValue,
                    "@Description", model.Description,
                    "@UpdatedBy", model.UpdatedBy
                );
                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);
                return true;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public bool Delete(int id)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_systemsetting_delete",
                    "@SettingID", id);
                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);
                return true;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public List<SystemSettingModel> Search(int pageIndex, int pageSize, out long total, string SettingKey, string Description, string option)
        {
            string msgError = "";
            total = 0;
            try
            {
                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msgError, "sp_systemsetting_search",
                    "@page_index", pageIndex,
                    "@page_size", pageSize,
                    "@SettingKey", SettingKey,
                    "@Description", Description,
                    "@option", option);
                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);
                if (dt.Rows.Count > 0)
                    total = (long)dt.Rows[0]["RecordCount"];
                return dt.ConvertTo<SystemSettingModel>().ToList();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
    }
}

