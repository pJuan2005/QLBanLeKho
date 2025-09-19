using System;
using System.Collections.Generic;
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
        public int? SupplierID { get; set; }         // Mã nhà cung cấp (nullable)
        public string Unit { get; set; }             // Đơn vị tính
        public decimal Price { get; set; }           // Giá bán
        public int MinStock { get; set; }            // Tồn kho tối thiểu (default 0)
        public string Status { get; set; }

    }
}
