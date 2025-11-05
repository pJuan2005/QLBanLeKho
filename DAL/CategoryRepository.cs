using DAL.Helper;
using Microsoft.VisualBasic;
using Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices.Marshalling;
using System.Text;
using System.Threading.Tasks;

namespace DAL
{
    public class CategoryRepository:ICategoryRepository
    {
        private IDatabaseHelper _dbHelper;
        public CategoryRepository(IDatabaseHelper dbHelper)
        {
            _dbHelper = dbHelper;
        }

        public CategoryModel GetDatabyID(int id)
        {
            string msgError = "";
            try
            {
                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msgError, "sp_category_get_by_id", "@CategoryID", id);
                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);
                return dt.ConvertTo<CategoryModel>().FirstOrDefault();
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }

        public bool Create(CategoryModel model)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_category_create", "@CategoryName", model.CategoryName, "@Description", model.Description
                    , "@VATRate", model.VATRate);
                if ((result != null && !string.IsNullOrEmpty(result.ToString())) || !string.IsNullOrEmpty(msgError))
                    throw new Exception(Convert.ToString(result) + msgError);
                return true;

            }
            catch(Exception ex)
            {
                throw ex;
            }
        }

        public bool Update(CategoryModel model)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_category_update", "@CategoryID", model.CategoryID, "@CategoryName", model.CategoryName, "@Description", model.Description, "@VATRate",model.VATRate);
                if ((result != null && !string.IsNullOrEmpty(result.ToString())) || !string.IsNullOrEmpty(msgError))
                    throw new Exception(Convert.ToString(result) + msgError);
                return true;

            }catch(Exception ex)
            {
                throw ex;
            }
        }

        public bool Delete(int id)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_category_delete", "@CategoryID", id);
                if ((result != null && !string.IsNullOrEmpty(result.ToString()))|| !string.IsNullOrEmpty(msgError))
                    throw new Exception(Convert.ToString(result)+msgError);
                return true;

            }catch(Exception ex)
            {
                throw ex;
            }
        }


        public List<CategoryModel> Search(int pageIndex, int pageSize, out long total, int? CategoryID, string CategoryName, string option)
        {
            string msgError = "";
            total = 0;
            try
            {
                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msgError, "sp_category_search",
                    "@page_index", pageIndex,
                    "@page_size", pageSize,
                    "@CategoryName", CategoryName,
                    "@option", option,
                    "@CategoryID", CategoryID);
                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);
                if (dt.Rows.Count > 0) total = (long)dt.Rows[0]["RecordCount"];
                return dt.ConvertTo<CategoryModel>().ToList();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        public List<CategoryModel> Search(
            int pageIndex, int pageSize, out long total,
            int? CategoryID, string CategoryName, string option,
            decimal? vatExact, decimal? vatFrom, decimal? vatTo)
        {
            string msgError = "";
            total = 0;

            try
            {
                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(
                    out msgError,
                    "sp_category_search",
                    "@page_index", pageIndex,
                    "@page_size", pageSize,
                    "@CategoryName", CategoryName ?? string.Empty,
                    "@option", option ?? string.Empty,
                    "@CategoryID", CategoryID,
                    "@vat_exact", vatExact,   // NULL nếu không lọc exact
                    "@vat_from", vatFrom,    // NULL nếu không lọc khoảng
                    "@vat_to", vatTo       // NULL nếu không lọc khoảng
                );

                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);

                if (dt.Rows.Count > 0)
                {
                    var rc = dt.Rows[0]["RecordCount"];
                    if (rc != null && rc != DBNull.Value)
                        total = Convert.ToInt64(rc);
                }

                return dt.ConvertTo<CategoryModel>().ToList();
            }
            catch (Exception)
            {
                // có thể log ở đây nếu cần
                throw;
            }
        }

    }
}
