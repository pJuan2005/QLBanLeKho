using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model
{
    public class ApSupplierModel
    {
        public class ListAp
        {
            public int SupplierID { get; set; }
            public string SupplierName { get; set; }
            public decimal CurrentPayable { get; set; }
        }

        public class DetailAp
        {
            public int SupplierID { get; set; }
            public string SupplierName { get; set; }
            public decimal ReceivedTotal { get; set; }//tổng số tiền phải trả từ phiếu nhập(goodsreceipts)
            public decimal PaymentsTotal { get; set; }
            public decimal CurrentPayable { get; set; }
        }

    }
}
