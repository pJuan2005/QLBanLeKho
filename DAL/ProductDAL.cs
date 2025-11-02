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
                throw ex;
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
                    "@Unit", model.Unit,
                    "@MinStock", model.MinStock,
                    "@Status", model.Status,
                    "@Image", model.Image,
                    "@VATRate", model.VATRate,
                    "@Quantity ", model.Quantity

                );

                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);

                if (result != null && int.TryParse(result.ToString(), out int newId))
                    model.ProductID = newId;

                return true; 
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        

        public bool Update(ProductModel model)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_product_update",
                    "@ProductID", model.ProductID,
                    "@SKU", model.SKU,
                    "@Barcode", model.Barcode,
                    "@ProductName", model.ProductName,
                    "@CategoryID", model.CategoryID,
                    "@Unit", model.Unit,
                    "@MinStock", model.MinStock,
                    "@Status", model.Status,
                    "@Image", model.Image,
                    "@VATRate", model.VATRate,
                    "@Quantity ", model.Quantity
                );
                if ((result != null && !string.IsNullOrEmpty(result.ToString())) || !string.IsNullOrEmpty(msgError))
                {
                    throw new Exception(Convert.ToString(result) + msgError);
                }
                return true;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public bool Delete(int productId)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_product_delete",
                    "@ProductID", productId
                );

                if (!string.IsNullOrEmpty(msgError))
                {
                    Console.WriteLine("Lỗi: " + msgError);
                    return false;
                }

                Console.WriteLine("Thành công: " + Convert.ToString(result));
                return true;
            }
            catch (Exception ex)
            {
                Console.WriteLine("Exception: " + ex.Message);
                return false;
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
                throw ex;
            }
        }
    }
}
