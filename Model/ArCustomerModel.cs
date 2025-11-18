using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model
{
    public class ArCustomerModel
    {
        //list công nợ khách hàng
        public class ListAr
        {
            public int CustomerID { get; set; }
            public string CustomerName { get; set; }
            public string Phone { get; set; }
            public decimal DebtLimit { get; set; }
            public decimal CurrentDebt { get; set; }
            public bool IsOverLimit { get; set; }
        }

        // chi tiết công nợ của 1 khách hàng
        public class DetailAr
        {
            public int CustomerID { get; set; }
            public string CustomerName { get; set; }
            public decimal DebtLimit { get; set; }
            public decimal SalesTotal { get; set; } //tổng tiền bán đã phát sinh
            public decimal PaymentsTotal { get; set; }
            public decimal CurrentDebt { get; set; }
        }

        //check giới hạn công nợ cúa khách hàng
        public class CheckLimitResult
        {
            public bool Ok { get; set; }
            public int CustomerID { get; set; }
            public decimal DebtLimit { get; set;  }
            public decimal CurrentDebt { get; set; }
            public decimal NewAmount { get; set; } //nợ từ đơn mợi
            public decimal Prepay { get; set; } //tiền khách trả ngay
            public decimal ProjectedDebt { get; set; } //nợ dự kiến sau đơn
            public decimal OverBy { get; set; }//mức vượt hạn mức
            public string Message { get; set; }
        }

    }
}
