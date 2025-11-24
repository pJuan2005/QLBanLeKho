using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using BLL;
using System.Reflection;
using BLL.Interfaces;
using Model;
using AdminApi.Services.Interface;
using System.Text.Json;
using System.Globalization;
using Microsoft.AspNetCore.Authorization;

namespace CoreApi.Controllers
{
    [Authorize] // tất cả endpoint yêu cầu đăng nhập
    [Route("api/promotions")]
    [ApiController]
    public class PromotionsController : ControllerBase
    {
        private IPromotionsBusiness _promotionsBusiness;
        private IAuditLogger _auditLogger;

        public PromotionsController(IPromotionsBusiness promotionsBusiness, IAuditLogger auditLogger)
        {
            _promotionsBusiness = promotionsBusiness;
            _auditLogger = auditLogger;
        }

        // ===== 1) Tạo khuyến mãi =====
        // Chỉ Admin + Kế toán được tạo / cấu hình khuyến mãi
        [Authorize(Roles = "Admin,KeToan")]
        [HttpPost("create")]
        public PromotionsModel Create([FromBody] PromotionsModel model)
        {
            _promotionsBusiness.Create(model);
            _auditLogger.Log(
                action: $"Create promotion: {model.PromotionName}",
                entityName: "Promotions",
                entityId: model.PromotionID,
                operation: "CREATE",
                details: JsonSerializer.Serialize(model)
            );
            return model;
        }

        // ===== 2) Cập nhật khuyến mãi =====
        [Authorize(Roles = "Admin,KeToan")]
        [HttpPost("update")]
        public PromotionsModel Update([FromBody] PromotionsModel model)
        {
            _promotionsBusiness.Update(model);
            _auditLogger.Log(
                action: $"Update promotion {model.PromotionName}",
                entityName: "Promotions",
                entityId: model.PromotionID,
                operation: "UPDATE",
                details: JsonSerializer.Serialize(model)
            );
            return model;
        }

        // ===== 3) Xoá khuyến mãi =====
        [Authorize(Roles = "Admin,KeToan")]
        [HttpPost("delete")]
        public IActionResult Delete([FromBody] PromotionsModel model)
        {
            _promotionsBusiness.Delete(model);
            _auditLogger.Log(
                action: $"Delete promotion {model.PromotionName}",
                entityName: "Promotions",
                entityId: model.PromotionID,
                operation: "DELETE",
                details: null
            );
            return Ok(new { data = "ok" });
        }

        // ===== 4) Xem chi tiết 1 khuyến mãi =====
        // Ai cũng cần xem để biết áp dụng: Admin, Thu ngân, Thủ kho, Kế toán
        [Authorize(Roles = "Admin,ThuNgan,ThuKho,KeToan")]
        [HttpGet("get-by-id/{id}")]
        public PromotionsModel GetDatabyID(int id)
        {
            return _promotionsBusiness.GetDatabyID(id);
        }

        // ===== 5) Search danh sách khuyến mãi =====
        // Dùng cho màn hình quản lý + POS để check khuyến mãi còn hiệu lực
        [Authorize(Roles = "Admin,ThuNgan,ThuKho,KeToan")]
        [HttpPost("search")]
        public ResponseModel Search([FromBody] Dictionary<string, object> formData)
        {
            var response = new ResponseModel();
            try
            {
                var pageIndex = int.Parse(formData["pageIndex"].ToString());
                var pageSize = int.Parse(formData["pageSize"].ToString());

                DateTime? fromDate = null, toDate = null;
                string status = "";

                if (formData.Keys.Contains("fromDate") && DateTime.TryParse(Convert.ToString(formData["fromDate"]), out var fd))
                    fromDate = fd;
                if (formData.Keys.Contains("toDate") && DateTime.TryParse(Convert.ToString(formData["toDate"]), out var td))
                    toDate = td;
                if (formData.Keys.Contains("status"))
                    status = Convert.ToString(formData["status"]);

                var data = _promotionsBusiness.Search(pageIndex, pageSize, out long total, fromDate, toDate, status);

                // 🔹 Tự động chuyển status sang "Expired" nếu đã hết hạn
                foreach (var promo in data)
                {
                    if (promo.EndDate <= DateTime.Today && promo.Status == "Active")
                    {
                        promo.Status = "Expired";

                        _promotionsBusiness.Update(new PromotionsModel
                        {
                            PromotionID = promo.PromotionID,
                            PromotionName = promo.PromotionName,
                            Type = promo.Type,
                            Value = promo.Value,
                            StartDate = promo.StartDate,
                            EndDate = promo.EndDate,
                            CategoryID = promo.CategoryID,
                            Status = "Expired"
                        });
                    }
                }

                response.TotalItems = total;
                response.Data = data;
                response.Page = pageIndex;
                response.PageSize = pageSize;
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return response;
        }
    }
}
