namespace Model
{
    public class ProductModel
    {
        public int ProductID { get; set; }
        public string SKU { get; set; }
        public string Barcode { get; set; }
        public string ProductName { get; set; }
        public int? CategoryID { get; set; }

        public decimal? UnitPrice { get; set; }
        public string? Unit { get; set; }
        public int? MinStock { get; set; }
        public string? Status { get; set; }
        public decimal? VATRate { get; set; }
        public string? Image { get; set; }
        public int? Quantity { get; set; }
    }

    public class ProductSearchRequest
    {
        public int page { get; set; }
        public int pageSize { get; set; }
        public int? ProductID { get; set; }
        public string? SKU { get; set; }
        public string? Barcode { get; set; }
        public string? ProductName { get; set; }
        public int? CategoryID { get; set; }
        public string? Status { get; set; }
        public decimal? MinPrice { get; set; }
        public decimal? MaxPrice { get; set; }
    }
}