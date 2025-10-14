// File: DAL/SystemDAL.cs
using DAL.Interfaces;
using DAL.Helper;
using Model;
using System;
using System.Collections.Generic;

namespace DAL
{
    public class SystemDAL : ISystemDAL
    {
        private readonly IDatabaseHelper _dbHelper;

        public SystemDAL(IDatabaseHelper dbHelper)
        {
            _dbHelper = dbHelper;
        }


        public SystemSettingModel GetDatabyID(int id)
        {
            string msgError = "";
            try
            {
                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msgError, "sp_system_settings_get_all",
                     "@SettingID", id);
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
                var result = _dbHelper.ExecuteScalarSProcedure(out msgError, "sp_system_setting_create",
                    "@Setting", model.Setting,
                    "@Information", model.Information);

                if (!string.IsNullOrEmpty(msgError))
                {
                    throw new Exception(msgError);
                }

                // Nếu tạo thành công, gán ID mới trả về vào model
                if (result != null && int.TryParse(result.ToString(), out int newId))
                {
                    model.SettingID = newId;
                }
                return true;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        // ✅ THÊM TRIỂN KHAI CHO PHƯƠNG THỨC DELETE
        public bool Delete(int id)
        {
            string msgError = "";
            try
            {
                // ExecuteScalarSProcedure cũng có thể dùng cho các lệnh không trả về giá trị
                _dbHelper.ExecuteScalarSProcedure(out msgError, "sp_system_setting_delete",
                    "@SettingID", id);

                if (!string.IsNullOrEmpty(msgError))
                {
                    throw new Exception(msgError);
                }
                return true;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        // File: DAL/SystemDAL.cs

        public bool Update(SystemSettingModel model) // Nhận vào một model duy nhất
        {
            string msgError = "";
            try
            {
                // Gọi SP và truyền đủ 3 tham số, BAO GỒM CẢ @SettingID
                _dbHelper.ExecuteScalarSProcedure(out msgError, "sp_system_setting_update",
                    "@SettingID", model.SettingID, // <-- DÒNG QUAN TRỌNG BỊ THIẾU
                    "@Setting", model.Setting,
                    "@Information", model.Information
                );

                if (!string.IsNullOrEmpty(msgError))
                {
                    throw new Exception(msgError);
                }
                return true;
            }
            catch (Exception)
            {
                throw;
            }
        }
        

        public List<SystemSettingModel> Search(SystemSettingSearchRequest request, out long total)
        {
            string msgError = "";
            total = 0;
            try
            {
                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msgError, "sp_system_setting_search",
                    "@page_index", request.page,              
                    "@page_size", request.pageSize,          
                    "@SettingID", request.SettingID,        
                    "@Setting", request.Setting,                    
                    "@Information", request.Information     
                );

                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);
                if (dt.Rows.Count > 0) total = (long)dt.Rows[0]["RecordCount"];
                return dt.ConvertTo<SystemSettingModel>().ToList();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
    }
}