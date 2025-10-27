using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
namespace Model
{
    public class ProductModel
    {
        
        public int ProductID { get; set; }           // Mã sản phẩm (khóa chính)
        public string SKU { get; set; }              // Mã SKU (unique, not null)
        public string Barcode { get; set; }          // Mã barcode (unique, có thể null)
        public string ProductName { get; set; }      // Tên sản phẩm
        public int? CategoryID { get; set; }         // Mã loại hàng (nullable vì có thể chưa gán)
        public string Unit { get; set; }             // Đơn vị tính
        public int MinStock { get; set; }            // Tồn kho tối thiểu (default 0)
        public string Status { get; set; }
        //public string Image { get; set; }
        public decimal? VATRate { get; set; }

        [NotMapped] // Báo cho Entity Framework/Dapper biết không map cột này vào DB
        public string Image { get; set; } // Thuộc tính mới để chứa URL đầy đủ
        public int Quantity { get; set; }  

    }







    public class ProductSearchRequest
    {
        public int page { get; set; }
        public int pageSize { get; set; }
        public int? ProductID { get; set; }
        public string SKU { get; set; }
        public string ProductName { get; set; }
        public int? CategoryID { get; set; }
        public string Status { get; set; }

    }
}
