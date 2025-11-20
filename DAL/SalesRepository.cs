using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Model;
using DAL.Interfaces;
using DAL.Helper;


namespace DAL
{
    public class SalesRepository : ISalesRepository
    {
        private IDatabaseHelper _dbHelper;

        public SalesRepository(IDatabaseHelper dbHelper)
        {
            _dbHelper = dbHelper;
        }

        public SalesModel GetDatabyID(int id)
        {
            string msgError = "";
            try
            {
                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msgError, "sp_Sales_get_by_id",
                    "@SaleID", id);
                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);
                return dt.ConvertTo<SalesModel>().FirstOrDefault();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

            public bool Create(SalesModel model)
            {
                string msgError = "";
                try
                {
                    var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_Sales_create",
                        "@CustomerID", model.CustomerID,
                        "@UserID", model.UserID
                        
                        );
                    

                    if ((result != null && !string.IsNullOrEmpty(result.ToString())) || !string.IsNullOrEmpty(msgError))
                    {
                        throw new Exception(Convert.ToString(result) + msgError);
                    }
                    return true;
                }
                catch (Exception ex)
                {
                    throw;
                }
            }


        public bool Update(SalesModel model)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_Sales_update",
                    "@SaleID", model.SaleID,
                    "@CustomerID", model.CustomerID,
                    "@UserID", model.UserID,
                    "@SaleDate", model.SaleDate,
                    "@PaymentStatus", model.PaymentStatus,
                    "@TotalAmount", model.TotalAmount,
                    "@VATAmount", model.VATAmount);

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

        public bool Delete(SalesModel model)
        {
            string msgError = "";
            try
            {
                var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_Sales_delete",
                    "@SaleID", model.SaleID);

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

        public List<SalesModel> Search(int pageIndex, int pageSize, out long total, decimal? minTotalAmount, decimal? maxTotalAmount, string status, DateTime? fromDate, DateTime? toDate)
        {
            string msgError = "";
            total = 0;
            try
            {
                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(out msgError, "sp_Sales_search",
                    "@page_index", pageIndex,
                    "@page_size", pageSize,
                    "@MinTotalAmount", minTotalAmount,
                    "@MaxTotalAmount", maxTotalAmount,
                    "@Status", status,
                    "@FromDate", fromDate,
                    "@ToDate", toDate);

                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);

                if (dt.Rows.Count > 0)
                {
                    total = Convert.ToInt64(dt.Rows[0]["RecordCount"]);
                }

                return dt.ConvertTo<SalesModel>().ToList();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        //thêm hàm create trả về id của sales đó để insert vào saleitems, payment,...
        public int CreateReturnId(SalesModel model)
        {
            string msgError = "";
            var result = _dbHelper.ExecuteScalarSProcedureWithTransaction(out msgError, "sp_sales_create_return_id",
                "@CustomerId",model.CustomerID, "@UserId",model.UserID);
            if(!string.IsNullOrEmpty(msgError)) throw new Exception(msgError);
            if (result == null || string.IsNullOrEmpty(result.ToString()))
                throw new Exception("sp không trả về salesID");
            return Convert.ToInt32(result);
        }

        public SalesDashboardDto GetDashboard( decimal? minTotalAmount, decimal? maxTotalAmount, string status, DateTime? fromDate, DateTime? toDate,string keyword)
        {
            string msgError = "";
            try
            {
                var dt = _dbHelper.ExecuteSProcedureReturnDataTable(
                    out msgError, "sp_Sales_dashboard",
                    "@MinTotalAmount", minTotalAmount,
                    "@MaxTotalAmount", maxTotalAmount,
                    "@Status", status,
                    "@FromDate", fromDate,
                    "@ToDate", toDate,
                    "@Keyword", keyword
                );

                if (!string.IsNullOrEmpty(msgError))
                    throw new Exception(msgError);

                // SP trả về đúng 1 dòng
                if (dt.Rows.Count == 0) return new SalesDashboardDto();

                var row = dt.Rows[0];
                var result = new SalesDashboardDto
                {
                    TotalSales = Convert.ToInt32(row["TotalSales"]),
                    TotalRevenue = row["TotalRevenue"] != DBNull.Value
                        ? Convert.ToDecimal(row["TotalRevenue"])
                        : 0,
                    AvgOrderValue = row["AvgOrderValue"] != DBNull.Value
                        ? Convert.ToDecimal(row["AvgOrderValue"])
                        : 0,
                    PaidCount = Convert.ToInt32(row["PaidCount"]),
                    UnpaidCount = Convert.ToInt32(row["UnpaidCount"])
                };

                return result;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
        public List<SalesListItemDto> SearchList(int pageIndex, int pageSize, out long total,string status, DateTime? fromDate, DateTime? toDate,string keyword)
        {
            string msgError = "";
            total = 0;

            var dt = _dbHelper.ExecuteSProcedureReturnDataTable(
                out msgError, "sp_Sales_list_view",
                "@page_index", pageIndex,
                "@page_size", pageSize,
                "@Status", status,
                "@FromDate", fromDate,
                "@ToDate", toDate,
                "@Keyword", keyword
            );

            if (!string.IsNullOrEmpty(msgError))
                throw new Exception(msgError);

            if (dt.Rows.Count > 0)
                total = Convert.ToInt64(dt.Rows[0]["RecordCount"]);

            return dt.ConvertTo<SalesListItemDto>().ToList();
        }
        public SaleDetailDto GetDetail(int saleId)
        {
            string msgError = "";

            // 1) Header
            var dtHeader = _dbHelper.ExecuteSProcedureReturnDataTable(
                out msgError, "sp_Sales_detail_header",
                "@SaleID", saleId);
            if (!string.IsNullOrEmpty(msgError))
                throw new Exception(msgError);

            var header = dtHeader.ConvertTo<SaleDetailHeaderDto>().FirstOrDefault();

            // 2) Items
            var dtItems = _dbHelper.ExecuteSProcedureReturnDataTable(
                out msgError, "sp_Sales_detail_items",
                "@SaleID", saleId);
            if (!string.IsNullOrEmpty(msgError))
                throw new Exception(msgError);

            var items = dtItems.ConvertTo<SaleItemDetailDto>().ToList();

            // 3) Totals
            var dtTotals = _dbHelper.ExecuteSProcedureReturnDataTable(
                out msgError, "sp_Sales_detail_totals",
                "@SaleID", saleId);
            if (!string.IsNullOrEmpty(msgError))
                throw new Exception(msgError);

            var totals = dtTotals.ConvertTo<SaleTotalsDto>().FirstOrDefault()
                         ?? new SaleTotalsDto();

            return new SaleDetailDto
            {
                Sale = header,
                Items = items,
                Totals = totals
            };
        }

    }
}
