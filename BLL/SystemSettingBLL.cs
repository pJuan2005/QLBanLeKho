// File: BLL/SystemBLL.cs
using BLL.Interfaces;
using DAL.Interfaces;
using Model;
using System;
using System.Collections.Generic;
using System.Linq;

namespace BLL
{
    public class SystemBLL : ISystemBLL
    {
        private readonly ISystemDAL _res;

        public SystemBLL(ISystemDAL res)
        {
            _res = res;
        }
        public bool Create(SystemSettingModel model)
        {
            // Thêm logic nghiệp vụ ở đây nếu cần
            // Ví dụ: kiểm tra tên Setting không được để trống
            if (string.IsNullOrWhiteSpace(model.Setting))
            {
                throw new ArgumentException("Tên cài đặt (Setting) không được để trống.");
            }
            return _res.Create(model);
        }

        // ✅ THÊM TRIỂN KHAI CHO PHƯƠNG THỨC DELETE
        public bool Delete(int id)
        {
            if (id <= 0)
            {
                throw new ArgumentException("ID không hợp lệ.");
            }
            return _res.Delete(id);
        }

        // File: BLL/SystemBLL.cs

        public bool Update(SystemSettingModel model) // Nhận vào một model duy nhất
        {
            // Thêm các logic kiểm tra cần thiết
            if (model.SettingID <= 0)
            {
                throw new ArgumentException("SettingID không hợp lệ để cập nhật.");
            }
            if (string.IsNullOrWhiteSpace(model.Setting))
            {
                throw new ArgumentException("Tên cài đặt (Setting) không được để trống.");
            }

            // Gọi xuống DAL
            return _res.Update(model);
        }

        // ✅ Implementation cho phương thức mới
        // Với chức năng lấy tất cả, thường không cần thêm logic nghiệp vụ,
        // nên ta chỉ cần gọi thẳng xuống DAL.
        public SystemSettingModel GetDatabyID(int id)
        {
            return _res.GetDatabyID(id);
        }

        public List<SystemSettingModel> Search(SystemSettingSearchRequest request, out long total)
        {
            return _res.Search(request, out total);
        }
    }
}