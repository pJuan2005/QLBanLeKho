using DAL.Interfaces;
using DAL.Helper;
using Model;
using System;
using System.Collections.Generic;
using System.Linq;

namespace DAL
{
    public class ProductDAL : IDProductDAL
    {
        private readonly IDatabaseHelper _dbHelper;

        public ProductDAL(IDatabaseHelper dbHelper)
        {
            _dbHelper = dbHelper;
        }

        public ProductModel GetDatabyID(int id)
        {
            string msgError = "";
            try
            {
                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msgError, "sp_product_get_by_id",
                     "@ProductID", id);
                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);
                return dt.ConvertTo<ProductModel>().FirstOrDefault();
            }
            catch (Exception ex)
            {
                throw;
            }
        }

        public bool Create(ProductModel model)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_product_create",
                    "@SKU", model.SKU,
                    "@Barcode", model.Barcode,
                    "@ProductName", model.ProductName,
                    "@CategoryID", model.CategoryID,
                    "@UnitPrice", model.UnitPrice,
                    "@Unit", model.Unit,
                    "@MinStock", model.MinStock,
                    "@Status", model.Status,
                    "@ImageData", model.ImageData,
                    "@VATRate", model.VATRate,
                    "@Quantity", model.Quantity
                );

                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);

                if (result != null && int.TryParse(result.ToString(), out int newId))
                    model.ProductID = newId;

                return true;
            }
            catch (Exception ex)
            {
                throw;
            }
        }



        public bool Update(ProductModel model)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_product_update",
                    "@ProductID", model.ProductID,
                    "@SKU", (object?)model.SKU ?? DBNull.Value,
                    "@Barcode", (object?)model.Barcode ?? DBNull.Value,
                    "@ProductName", (object?)model.ProductName ?? DBNull.Value,
                    "@CategoryID", (object?)model.CategoryID ?? DBNull.Value,
                    "@UnitPrice", model.UnitPrice,
                    "@Unit", (object?)model.Unit ?? DBNull.Value,
                    "@MinStock", (object?)model.MinStock ?? DBNull.Value,
                    "@Status", (object?)model.Status ?? DBNull.Value,
                    "@ImageData", (object?)model.ImageData ?? DBNull.Value,
                    "@VATRate", (object?)model.VATRate ?? DBNull.Value,
                    "@Quantity", (object?)model.Quantity ?? DBNull.Value
                );

                // ✅ Chỉ bắn lỗi khi msgError có nội dung
                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);

                // (tuỳ chọn) bạn có thể log result nếu muốn
                return true;
            }
            catch { throw; }
        }


        public bool Delete(int productId)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(
                    out msgError, "sp_product_delete",
                    "@ProductID", productId);

                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError); // <-- bắn lỗi thay vì return false

                return true;
            }
            catch (Exception ex)
            {
                // log nếu muốn, nhưng nên bắn tiếp
                throw; // <-- đừng return false
            }
        }




        public List<ProductModel> Search(ProductSearchRequest request, out long total)
        {
            string msgError = "";
            total = 0;
            try
            {
                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msgError, "sp_product_search",
                    "@page_index", request.page,               // Thay đổi ở đây
                    "@page_size", request.pageSize,           // Thay đổi ở đây
                    "@ProductID", request.ProductID,         // Thay đổi ở đây
                    "@SKU", request.SKU,                     // Thay đổi ở đây
                    "@Barcode", request.Barcode,
                    "@ProductName", request.ProductName,     // Thay đổi ở đây
                    "@CategoryID", request.CategoryID,       // Thay đổi ở đây
                    "@Status", request.Status               // ✨ Thêm tham số Status
                );

                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);
                if (dt.Rows.Count > 0) total = (long)dt.Rows[0]["RecordCount"];
                return dt.ConvertTo<ProductModel>().ToList();
            }
            catch (Exception ex)
            {
                throw;
            }
        }
    }
}