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
<<<<<<< HEAD
        public int? CategoryID { get; set; }         // Mã loại hàng (nullable vì có thể chưa gán)
        public int? SupplierID { get; set; }         // Mã nhà cung cấp (nullable)
        public string Unit { get; set; }             // Đơn vị tính
        public decimal Price { get; set; }           // Giá bán
        public int MinStock { get; set; }            // Tồn kho tối thiểu (default 0)
        public string Status { get; set; }

    }


    //public class ProductSearchRequest
    //{
    //    public int? ProductID1 { get; set; }
    //    public string SKU1 { get; set; }
    //    public string ProductName1 { get; set; }
    //    public int? CategoryID1 { get; set; }
    //    public int? SupplierID1 { get; set; }
    //    public string Status1 { get; set; }
    //    public string Option1 { get; set; }
    //    public int Page1 { get; set; }
    //    public int PageSize1 { get; set; }
    //}

=======
        public int? CategoryID { get; set; }         // Mã loại hàng
        public int? SupplierID { get; set; }         // Mã nhà cung cấp
        public string Unit { get; set; }             // Đơn vị tính
        public decimal Price { get; set; }           // Giá bán
        public int MinStock { get; set; }            // Tồn kho tối thiểu
        public string Status { get; set; }           // Trạng thái
        public string Image { get; set; }            // 🆕 Link ảnh sản phẩm
    }


>>>>>>> bách


    public class ProductSearchRequest
    {
        public int page { get; set; }
        public int pageSize { get; set; }
        public int? ProductID { get; set; }
        public string SKU { get; set; }
        public string ProductName { get; set; }
        public int? CategoryID { get; set; }
        public int? SupplierID { get; set; }
        public string Status { get; set; }
        public string option { get; set; }
    }
}
