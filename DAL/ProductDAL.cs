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
            var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msgError,
                        "sp_product_get_by_id",
                        "@ProductID", id);

            if (!string.IsNullOrEmpty(msgError))
                throw new Exception(msgError);

            return dt.ConvertTo<ProductModel>().FirstOrDefault();
        }

        public bool Create(ProductModel model)
        {
            string msgError = "";

            var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(
                out msgError,
                "sp_product_create",
                "@SKU", model.SKU,
                "@Barcode", model.Barcode,
                "@ProductName", model.ProductName,
                "@CategoryID", model.CategoryID,
                "@UnitPrice", model.UnitPrice,
                "@Unit", model.Unit,
                "@MinStock", model.MinStock,
                "@Status", model.Status,
                "@Image", model.Image,
                "@VATRate", model.VATRate,
                "@Quantity", model.Quantity
            );

            if (!string.IsNullOrEmpty(msgError))
                throw new Exception(msgError);

            if (result != null && int.TryParse(result.ToString(), out int newId))
                model.ProductID = newId;

            return true;

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

            var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(
                out msgError,
                "sp_product_update",
                "@ProductID", model.ProductID,
                "@SKU", model.SKU,
                "@Barcode", model.Barcode,
                "@ProductName", model.ProductName,
                "@CategoryID", model.CategoryID,
                "@UnitPrice", model.UnitPrice,
                "@Unit", model.Unit,
                "@MinStock", model.MinStock,
                "@Status", model.Status,
                "@Image", model.Image,
                "@VATRate", model.VATRate,
                "@Quantity", model.Quantity
            );

            if (!string.IsNullOrEmpty(msgError))
                throw new Exception(msgError);

            return true;
        }


            var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(
                out msgError,
                "sp_product_update",
                "@ProductID", model.ProductID,
                "@SKU", model.SKU,
                "@Barcode", model.Barcode,
                "@ProductName", model.ProductName,
                "@CategoryID", model.CategoryID,
                "@UnitPrice", model.UnitPrice,
                "@Unit", model.Unit,
                "@MinStock", model.MinStock,
                "@Status", model.Status,
                "@Image", model.Image,
                "@VATRate", model.VATRate,
                "@Quantity", model.Quantity
            );

            if (!string.IsNullOrEmpty(msgError))
                throw new Exception(msgError);

            return true;
        }
        public bool Delete(int productId)
        {
            string msgError = "";

            var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(
                out msgError,
                "sp_product_delete",
                "@ProductID", productId);

            if (!string.IsNullOrEmpty(msgError))
                throw new Exception(msgError);

            return true;
        }

        public List<ProductModel> Search(ProductSearchRequest req, out long total)
        {
            string msgError = "";
            total = 0;
            var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msgError,
                "sp_product_search",
                "@page_index", req.page,
                "@page_size", req.pageSize,
                "@ProductID", req.ProductID,
                "@SKU", req.SKU,
                "@Barcode", req.Barcode,
                "@ProductName", req.ProductName,
                "@CategoryID", req.CategoryID,
                "@Status", req.Status,
                "@MinPrice", req.MinPrice,
                "@MaxPrice", req.MaxPrice
            );

            if (!string.IsNullOrEmpty(msgError))
                throw new Exception(msgError);

            if (dt.Rows.Count > 0)
                total = Convert.ToInt64(dt.Rows[0]["TotalCount"]);

            return dt.ConvertTo<ProductModel>().ToList();
        }
    }

}