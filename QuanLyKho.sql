create database QuanLyKho
use  QuanLyKho


CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY, -- Mã người dùng
    Username VARCHAR(50) UNIQUE NOT NULL, -- Tên đăng nhập
    PasswordHash VARCHAR(255) NOT NULL, -- Mật khẩu đã mã hóa
    Role NVARCHAR(20) NOT NULL, -- Vai trò hệ thống (Admin, ThuNgan, ThuKho, KeToan)
    FullName NVARCHAR(100), -- Họ tên
    Email NVARCHAR(100), -- Email
    Phone VARCHAR(20) -- Số điện thoại
);

CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY, -- Mã loại hàng
    CategoryName NVARCHAR(100) NOT NULL, -- Tên loại hàng
    Description NVARCHAR(255) -- Mô tả
);

CREATE TABLE Suppliers (
    SupplierID INT IDENTITY(1,1) PRIMARY KEY, -- Mã nhà cung cấp
    SupplierName NVARCHAR(100) NOT NULL, -- Tên nhà cung cấp
    Address NVARCHAR(255), -- Địa chỉ
    Phone VARCHAR(20), -- Số điện thoại
    Email NVARCHAR(100) -- Email
);

CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY, -- Mã khách hàng
    CustomerName NVARCHAR(100) NOT NULL, -- Tên khách hàng
    Phone VARCHAR(20), -- Số điện thoại
    Email NVARCHAR(100), -- Email
    Address NVARCHAR(255), -- Địa chỉ
    DebtLimit DECIMAL(18,2) DEFAULT 0 -- Hạn mức công nợ
);

CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY, -- Mã sản phẩm
    SKU VARCHAR(50) UNIQUE NOT NULL, -- Mã SKU
    Barcode VARCHAR(50) UNIQUE, -- Mã barcode
    ProductName NVARCHAR(100) NOT NULL, -- Tên sản phẩm
    CategoryID INT, -- Mã loại hàng
    SupplierID INT, -- Mã nhà cung cấp
    Unit NVARCHAR(20), -- Đơn vị tính
    Price DECIMAL(18,2) NOT NULL, -- Giá bán
    MinStock INT DEFAULT 0, -- Tồn kho tối thiểu
    Status NVARCHAR(20) DEFAULT 'Active', -- Trạng thái
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID),
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID)
);

CREATE TABLE PurchaseOrders (
    POID INT IDENTITY(1,1) PRIMARY KEY, -- Mã đơn mua hàng
    SupplierID INT NOT NULL, -- Mã nhà cung cấp
    OrderDate DATE NOT NULL, -- Ngày đặt hàng
    TotalAmount DECIMAL(18,2), -- Tổng tiền
    Status NVARCHAR(20) DEFAULT 'Pending', -- Trạng thái đơn
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID)
);

CREATE TABLE PurchaseOrderDetails (
    POID INT, -- Mã đơn mua hàng
    ProductID INT, -- Mã sản phẩm
    Quantity INT NOT NULL, -- Số lượng
    UnitPrice DECIMAL(18,2) NOT NULL, -- Đơn giá
    PRIMARY KEY (POID, ProductID),
    FOREIGN KEY (POID) REFERENCES PurchaseOrders(POID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

CREATE TABLE GoodsReceipts (
    ReceiptID INT IDENTITY(1,1) PRIMARY KEY, -- Mã phiếu nhập kho
    POID INT, -- Mã đơn mua hàng
    ReceiptDate DATE NOT NULL, -- Ngày nhập kho
    TotalAmount DECIMAL(18,2), -- Tổng tiền
    FOREIGN KEY (POID) REFERENCES PurchaseOrders(POID)
);


CREATE TABLE GoodsReceiptDetails (
    ReceiptID INT, -- Mã phiếu nhập kho
    ProductID INT, -- Mã sản phẩm
    Quantity INT NOT NULL, -- Số lượng
    UnitPrice DECIMAL(18,2) NOT NULL, -- Đơn giá
    BatchNo VARCHAR(50), -- Số lô
    ExpiryDate DATE, -- Hạn dùng
    PRIMARY KEY (ReceiptID, ProductID),
    FOREIGN KEY (ReceiptID) REFERENCES GoodsReceipts(ReceiptID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

CREATE TABLE Promotions (
    PromotionID INT IDENTITY(1,1) PRIMARY KEY, -- Mã khuyến mãi
    PromotionName NVARCHAR(100) NOT NULL, -- Tên khuyến mãi
    Type NVARCHAR(20) NOT NULL, -- Loại giảm giá (Percent/Value)
    Value DECIMAL(18,2) NOT NULL, -- Giá trị giảm
    StartDate DATE NOT NULL, -- Ngày bắt đầu
    EndDate DATE NOT NULL, -- Ngày kết thúc
    ProductGroup NVARCHAR(255) -- Nhóm sản phẩm áp dụng
);

CREATE TABLE Sales (
    SaleID INT IDENTITY(1,1) PRIMARY KEY, -- Mã đơn bán hàng
    CustomerID INT, -- Mã khách hàng
    UserID INT NOT NULL, -- Mã nhân viên (người bán)
    SaleDate DATETIME NOT NULL, -- Ngày bán
    TotalAmount DECIMAL(18,2), -- Tổng tiền
    VATAmount DECIMAL(18,2), -- Thuế VAT
    PromotionID INT, -- Mã khuyến mãi
    PaymentStatus NVARCHAR(20) DEFAULT 'Unpaid', -- Trạng thái thanh toán
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (PromotionID) REFERENCES Promotions(PromotionID)
);

CREATE TABLE SalesItems (
    SaleID INT, -- Mã đơn bán hàng
    ProductID INT, -- Mã sản phẩm
    Quantity INT NOT NULL, -- Số lượng
    UnitPrice DECIMAL(18,2) NOT NULL, -- Đơn giá
    Discount DECIMAL(18,2) DEFAULT 0, -- Giảm giá
    PRIMARY KEY (SaleID, ProductID),
    FOREIGN KEY (SaleID) REFERENCES Sales(SaleID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

CREATE TABLE Returns (
    ReturnID INT IDENTITY(1,1) PRIMARY KEY, -- Mã phiếu trả hàng
    SaleID INT NOT NULL, -- Mã đơn bán hàng
    CustomerID INT NOT NULL, -- Mã khách hàng
    ReturnDate DATE NOT NULL, -- Ngày trả hàng
    Reason NVARCHAR(255), -- Lý do trả
    FOREIGN KEY (SaleID) REFERENCES Sales(SaleID),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

CREATE TABLE Invoices (
    InvoiceID INT IDENTITY(1,1) PRIMARY KEY, -- Mã hóa đơn
    SaleID INT UNIQUE NOT NULL, -- Mã đơn bán hàng
    InvoiceNo VARCHAR(50) UNIQUE NOT NULL, -- Số hóa đơn
    InvoiceDate DATE NOT NULL, -- Ngày lập hóa đơn
    TotalAmount DECIMAL(18,2), -- Tổng tiền
    VATAmount DECIMAL(18,2), -- Thuế VAT
    FOREIGN KEY (SaleID) REFERENCES Sales(SaleID)
);

CREATE TABLE Payments (
    PaymentID INT IDENTITY(1,1) PRIMARY KEY, -- Mã thanh toán
    CustomerID INT, -- Mã khách hàng
    SupplierID INT, -- Mã nhà cung cấp
    Amount DECIMAL(18,2) NOT NULL, -- Số tiền
PaymentDate DATE NOT NULL, -- Ngày thanh toán
    Method NVARCHAR(20) NOT NULL, -- Hình thức thanh toán
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID)
);

CREATE TABLE StockCards (
    StockID INT IDENTITY(1,1) PRIMARY KEY, -- Mã thẻ kho
    ProductID INT NOT NULL, -- Mã sản phẩm
    TransactionType NVARCHAR(10) NOT NULL, -- Loại giao dịch (IN/OUT)
    Quantity INT NOT NULL, -- Số lượng
    Balance INT NOT NULL, -- Tồn sau giao dịch
    RefID INT, -- Mã tham chiếu chứng từ
    TransactionDate DATETIME NOT NULL, -- Ngày giao dịch
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

INSERT INTO Users (Username, PasswordHash, Role, FullName, Email, Phone)
VALUES 
('admin', '123456', 'Admin', N'Nguyễn Văn A', 'admin@kho.com', '0901111111'),
('thungan1', '123456', 'ThuNgan', N'Trần Thị B', 'b@kho.com', '0902222222'),
('thukho1', '123456', 'ThuKho', N'Lê Văn C', 'c@kho.com', '0903333333'),
('ketoan1', '123456', 'KeToan', N'Phạm Thị D', 'd@kho.com', '0904444444');


INSERT INTO Categories (CategoryName, Description)
VALUES 
(N'Laptop', N'Máy tính xách tay'),
(N'Điện thoại', N'Smartphone'),
(N'Phụ kiện', N'Tai nghe, sạc, cáp...');


INSERT INTO Suppliers (SupplierName, Address, Phone, Email)
VALUES 
(N'Công ty FPT', N'Hà Nội', '0241111111', 'contact@fpt.com'),
(N'Công ty Viettel', N'Hồ Chí Minh', '0282222222', 'support@viettel.com');


INSERT INTO Customers (CustomerName, Phone, Email, Address, DebtLimit)
VALUES 
(N'Nguyễn Văn Khách', '0905555555', 'khach1@gmail.com', N'Hà Nội', 5000000),
(N'Trần Thị Người Mua', '0906666666', 'khach2@gmail.com', N'Hồ Chí Minh', 3000000);


INSERT INTO Products (SKU, Barcode, ProductName, CategoryID, SupplierID, Unit, Price, MinStock, Status)
VALUES 
('LAP001', '1111111111111', N'Laptop Dell XPS', 1, 1, N'Cái', 25000000, 5, 'Active'),
('DT001', '2222222222222', N'iPhone 14 Pro', 2, 2, N'Cái', 30000000, 3, 'Active'),
('PK001', '3333333333333', N'Tai nghe AirPods', 3, 2, N'Cái', 5000000, 10, 'Active');


INSERT INTO PurchaseOrders (SupplierID, OrderDate, TotalAmount, Status)
VALUES 
(1, '2025-09-01', 55000000, 'Pending'),
(2, '2025-09-05', 30000000, 'Completed');


INSERT INTO PurchaseOrderDetails (POID, ProductID, Quantity, UnitPrice)
VALUES 
(1, 1, 2, 24000000), -- Dell XPS
(1, 3, 5, 4500000),  -- AirPods
(2, 2, 1, 29000000); -- iPhone 14 Pro


INSERT INTO GoodsReceipts (POID, ReceiptDate, TotalAmount)
VALUES 
(1, '2025-09-02', 48000000),
(2, '2025-09-06', 29000000);


INSERT INTO GoodsReceiptDetails (ReceiptID, ProductID, Quantity, UnitPrice, BatchNo, ExpiryDate)
VALUES 
(1, 1, 2, 24000000, 'BATCH-LAP-01', NULL),
(1, 3, 5, 4500000, 'BATCH-PK-01', '2026-12-31'),
(2, 2, 1, 29000000, 'BATCH-DT-01', '2027-01-01');


INSERT INTO Promotions (PromotionName, Type, Value, StartDate, EndDate, ProductGroup)
VALUES 
(N'Giảm giá Laptop 10%', 'Percent', 10, '2025-09-01', '2025-09-30', N'Laptop'),
(N'Giảm 1 triệu cho iPhone', 'Value', 1000000, '2025-09-05', '2025-09-20', N'Điện thoại');


INSERT INTO Sales (CustomerID, UserID, SaleDate, TotalAmount, VATAmount, PromotionID, PaymentStatus)
VALUES 
(1, 2, '2025-09-10', 25000000, 2500000, 1, 'Paid'),
(2, 2, '2025-09-12', 30000000, 3000000, 2, 'Unpaid');


INSERT INTO SalesItems (SaleID, ProductID, Quantity, UnitPrice, Discount)
VALUES 
(1, 1, 1, 25000000, 0),   -- Dell XPS
(2, 2, 1, 30000000, 1000000); -- iPhone 14 Pro


INSERT INTO Returns (SaleID, CustomerID, ReturnDate, Reason)
VALUES 
(2, 2, '2025-09-15', N'Khách đổi sang sản phẩm khác');


INSERT INTO Invoices (SaleID, InvoiceNo, InvoiceDate, TotalAmount, VATAmount)
VALUES 
(1, 'INV-0001', '2025-09-10', 25000000, 2500000),
(2, 'INV-0002', '2025-09-12', 30000000, 3000000);


INSERT INTO Payments (CustomerID, SupplierID, Amount, PaymentDate, Method)
VALUES 
(1, NULL, 25000000, '2025-09-11', N'Tiền mặt'),
(NULL, 1, 48000000, '2025-09-03', N'Chuyển khoản');


INSERT INTO StockCards (ProductID, TransactionType, Quantity, Balance, RefID, TransactionDate)
VALUES 
(1, 'IN', 2, 2, 1, '2025-09-02'),
(3, 'IN', 5, 5, 1, '2025-09-02'),
(2, 'IN', 1, 1, 2, '2025-09-06'),
(1, 'OUT', 1, 1, 1, '2025-09-10'),
(2, 'OUT', 1, 0, 2, '2025-09-12');

-- Hiển thị tất cả dữ liệu từ từng bảng
SELECT * FROM Users;
SELECT * FROM Categories;
SELECT * FROM Suppliers;
SELECT * FROM Customers;
SELECT * FROM Products;
SELECT * FROM PurchaseOrders;
SELECT * FROM PurchaseOrderDetails;
SELECT * FROM GoodsReceipts;
SELECT * FROM GoodsReceiptDetails;
SELECT * FROM Promotions;
SELECT * FROM Sales;
SELECT * FROM SalesItems;
SELECT * FROM Returns;
SELECT * FROM Invoices;
SELECT * FROM Payments;
SELECT * FROM StockCards;


CREATE PROCEDURE [dbo].[sp_product_get_by_id]
    @ProductID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM Products
    WHERE ProductID = @ProductID;
END;
GO


DROP PROCEDURE IF EXISTS sp_product_update;


CREATE PROCEDURE [dbo].[sp_product_create]
(
    @SKU VARCHAR(50),
    @Barcode VARCHAR(50) = NULL,
    @ProductName NVARCHAR(100),
    @CategoryID INT = NULL,
    @SupplierID INT = NULL,
    @Unit NVARCHAR(20) = NULL,
    @Price DECIMAL(18,2),
    @MinStock INT = 0,
    @Status NVARCHAR(20) = 'Active'
)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Products
    (
        SKU,
        Barcode,
        ProductName,
        CategoryID,
        SupplierID,
        Unit,
        Price,
        MinStock,
        Status
    )
    VALUES
    (
        @SKU,
        @Barcode,
        @ProductName,
        @CategoryID,
        @SupplierID,
        @Unit,
        @Price,
        @MinStock,
        @Status
    );

    -- Trả về ID vừa thêm (giúp frontend/backend biết sản phẩm nào vừa được tạo)
    SELECT SCOPE_IDENTITY() AS NewProductID;
END;
GO



CREATE PROCEDURE [dbo].[sp_product_update]
(
    @ProductID   INT,
    @SKU         VARCHAR(50) = NULL,
    @Barcode     VARCHAR(50) = NULL,
    @ProductName NVARCHAR(100) = NULL,
    @CategoryID  INT = NULL,
    @SupplierID  INT = NULL,
    @Unit        NVARCHAR(20) = NULL,
    @Price       DECIMAL(18,2) = NULL,
    @MinStock    INT = NULL,
    @Status      NVARCHAR(20) = NULL
)
AS
BEGIN
    UPDATE Products
    SET
        SKU         = IIF(@SKU IS NULL, SKU, @SKU),
        Barcode     = IIF(@Barcode IS NULL, Barcode, @Barcode),
        ProductName = IIF(@ProductName IS NULL, ProductName, @ProductName),
        CategoryID  = IIF(@CategoryID IS NULL, CategoryID, @CategoryID),
        SupplierID  = IIF(@SupplierID IS NULL, SupplierID, @SupplierID),
        Unit        = IIF(@Unit IS NULL, Unit, @Unit),
        Price       = IIF(@Price IS NULL, Price, @Price),
        MinStock    = IIF(@MinStock IS NULL, MinStock, @MinStock),
        Status      = IIF(@Status IS NULL, Status, @Status)
    WHERE ProductID = @ProductID;

    SELECT '';
END;
GO



DROP PROCEDURE IF EXISTS sp_product_update;
GO


EXEC sp_helptext 'sp_product_update';



CREATE PROCEDURE [dbo].[sp_product_search]
(
    @page_index  INT, 
    @page_size   INT,
    @ProductID   INT = NULL,
    @SKU         VARCHAR(50) = '',
    @ProductName NVARCHAR(100) = '',
    @CategoryID  INT = NULL,
    @SupplierID  INT = NULL,
    @Status      NVARCHAR(20) = '',
    @option      VARCHAR(50) = ''
)
AS
BEGIN
    DECLARE @RecordCount BIGINT;

    IF(@page_size <> 0)
    BEGIN
        SET NOCOUNT ON;

        SELECT (ROW_NUMBER() OVER(
                  ORDER BY 
                      CASE 
                          WHEN @option = 'NAME' THEN p.ProductName
                          WHEN @option = 'PRICE' THEN CAST(p.Price AS NVARCHAR)
                          ELSE p.ProductID
                      END ASC)) AS RowNumber,
               p.ProductID,
               p.SKU,
               p.Barcode,
               p.ProductName,
               p.CategoryID,
               p.SupplierID,
               p.Unit,
               p.Price,
               p.MinStock,
               p.Status
        INTO #Results1
        FROM Products AS p
        WHERE (@ProductID IS NULL OR p.ProductID = @ProductID)
          AND (@SKU = '' OR p.SKU LIKE '%' + @SKU + '%')
          AND (@ProductName = '' OR p.ProductName LIKE N'%' + @ProductName + '%')
          AND (@CategoryID IS NULL OR p.CategoryID = @CategoryID)
          AND (@SupplierID IS NULL OR p.SupplierID = @SupplierID)
          AND (@Status = '' OR p.Status = @Status);

        SELECT @RecordCount = COUNT(*) FROM #Results1;

        SELECT *, @RecordCount AS RecordCount
        FROM #Results1
        WHERE RowNumber BETWEEN(@page_index - 1) * @page_size + 1 
                            AND (((@page_index - 1) * @page_size + 1) + @page_size) - 1
           OR @page_index = -1;

        DROP TABLE #Results1; 
    END
    ELSE
    BEGIN
        SET NOCOUNT ON;

        SELECT (ROW_NUMBER() OVER(
                  ORDER BY 
                      CASE 
                          WHEN @option = 'NAME' THEN p.ProductName
                          WHEN @option = 'PRICE' THEN CAST(p.Price AS NVARCHAR)
                          ELSE p.ProductID
                      END ASC)) AS RowNumber,
               p.ProductID,
               p.SKU,
               p.Barcode,
               p.ProductName,
               p.CategoryID,
               p.SupplierID,
               p.Unit,
               p.Price,
               p.MinStock,
               p.Status
        INTO #Results2
        FROM Products AS p
        WHERE (@ProductID IS NULL OR p.ProductID = @ProductID)
          AND (@SKU = '' OR p.SKU LIKE '%' + @SKU + '%')
          AND (@ProductName = '' OR p.ProductName LIKE N'%' + @ProductName + '%')
          AND (@CategoryID IS NULL OR p.CategoryID = @CategoryID)
          AND (@SupplierID IS NULL OR p.SupplierID = @SupplierID)
          AND (@Status = '' OR p.Status = @Status);

        SELECT @RecordCount = COUNT(*) FROM #Results2;

        SELECT *, @RecordCount AS RecordCount
        FROM #Results2;

        DROP TABLE #Results2;
    END;
END;
GO




CREATE PROCEDURE [dbo].[sp_payment_get_by_id]
    @PaymentID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM Payments
    WHERE PaymentID = @PaymentID;
END;
GO



CREATE PROCEDURE [dbo].[sp_payment_create]
(
    @CustomerID INT = NULL,
    @SupplierID INT = NULL,
    @Amount DECIMAL(18,2),
    @PaymentDate DATE,
    @Method NVARCHAR(20)
)
AS
BEGIN
    INSERT INTO Payments
    (
        CustomerID,
        SupplierID,
        Amount,
        PaymentDate,
        Method
    )
    VALUES
    (
        @CustomerID,
        @SupplierID,
        @Amount,
        @PaymentDate,
        @Method
    );

    SELECT '';
END;
GO


CREATE PROCEDURE [dbo].[sp_payment_update]
(
    @PaymentID   INT,
    @CustomerID  INT = NULL,
    @SupplierID  INT = NULL,
    @Amount      DECIMAL(18,2),
    @PaymentDate DATE,
    @Method      NVARCHAR(20)
)
AS
BEGIN
    UPDATE Payments
    SET
        CustomerID = IIF(@CustomerID IS NULL, CustomerID, @CustomerID),
        SupplierID = IIF(@SupplierID IS NULL, SupplierID, @SupplierID),
        Amount     = IIF(@Amount IS NULL, Amount, @Amount),
        PaymentDate= IIF(@PaymentDate IS NULL, PaymentDate, @PaymentDate),
        Method     = IIF(@Method IS NULL, Method, @Method)
    WHERE PaymentID = @PaymentID;

    SELECT '';
END;
GO



DROP PROCEDURE [sp_payment_search]

CREATE PROCEDURE [dbo].[sp_payment_search]
(
    @page_index  INT, 
    @page_size   INT,
    @PaymentID   INT = NULL,
    @CustomerID  INT = NULL,
    @SupplierID  INT = NULL,
	@Amount      DECIMAL(18,2) = NULL,  -- thêm vào
    @PaymentDate DATETIME = NULL,       -- thêm vào
    @Method      NVARCHAR(20) = '',
    @option      VARCHAR(50) = ''
)
AS
BEGIN
    DECLARE @RecordCount BIGINT;

    IF(@page_size <> 0)
    BEGIN
        SET NOCOUNT ON;

        SELECT (ROW_NUMBER() OVER(
                  ORDER BY 
                      CASE 
                          WHEN @option = 'DATE' THEN CONVERT(NVARCHAR, p.PaymentDate, 23)
                          WHEN @option = 'AMOUNT' THEN CAST(p.Amount AS NVARCHAR)
                          ELSE p.PaymentID
                      END ASC)) AS RowNumber,
               p.PaymentID,
               p.CustomerID,
               p.SupplierID,
               p.Amount,
               p.PaymentDate,
               p.Method
        INTO #Results1
        FROM Payments AS p
        WHERE (@PaymentID IS NULL OR p.PaymentID = @PaymentID)
          AND (@CustomerID IS NULL OR p.CustomerID = @CustomerID)
          AND (@SupplierID IS NULL OR p.SupplierID = @SupplierID)
          AND (@Method = '' OR p.Method LIKE N'%' + @Method + '%');

        SELECT @RecordCount = COUNT(*) FROM #Results1;

        SELECT *, @RecordCount AS RecordCount
        FROM #Results1
        WHERE RowNumber BETWEEN(@page_index - 1) * @page_size + 1 
                            AND (((@page_index - 1) * @page_size + 1) + @page_size) - 1
           OR @page_index = -1;

        DROP TABLE #Results1; 
    END
    ELSE
    BEGIN
        SET NOCOUNT ON;

        SELECT (ROW_NUMBER() OVER(
                  ORDER BY 
                      CASE 
                          WHEN @option = 'DATE' THEN CONVERT(NVARCHAR, p.PaymentDate, 23)
                          WHEN @option = 'AMOUNT' THEN CAST(p.Amount AS NVARCHAR)
                          ELSE p.PaymentID
                      END ASC)) AS RowNumber,
               p.PaymentID,
               p.CustomerID,
               p.SupplierID,
               p.Amount,
               p.PaymentDate,
               p.Method
        INTO #Results2
        FROM Payments AS p
        WHERE (@PaymentID IS NULL OR p.PaymentID = @PaymentID)
          AND (@CustomerID IS NULL OR p.CustomerID = @CustomerID)
          AND (@SupplierID IS NULL OR p.SupplierID = @SupplierID)
          AND (@Method = '' OR p.Method LIKE N'%' + @Method + '%');

        SELECT @RecordCount = COUNT(*) FROM #Results2;

        SELECT *, @RecordCount AS RecordCount
        FROM #Results2;

        DROP TABLE #Results2;
    END;
END;
GO



CREATE PROCEDURE [dbo].[sp_product_delete]
    @ProductID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Xóa dữ liệu liên quan trước (nếu bạn muốn xóa tất cả dấu vết của sản phẩm)
    DELETE FROM SalesItems WHERE ProductID = @ProductID;
    DELETE FROM StockCards WHERE ProductID = @ProductID;
    DELETE FROM GoodsReceiptDetails WHERE ProductID = @ProductID;
    DELETE FROM PurchaseOrderDetails WHERE ProductID = @ProductID;

    -- Cuối cùng xóa trong bảng Products
    DELETE FROM Products
    WHERE ProductID = @ProductID;

    SELECT 'Xóa sản phẩm thành công (cứng)' AS Message;
END;
GO



DROP PROCEDURE [dbo].[sp_product_delete];



CREATE PROCEDURE [dbo].[sp_payment_delete]
    @PaymentID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Vì bảng Payments chưa có liên kết trực tiếp đến bảng con,
    -- nên chỉ cần xóa bản ghi theo PaymentID
    DELETE FROM Payments
    WHERE PaymentID = @PaymentID;

    -- Trả về thông báo
    SELECT 'Xóa payment thành công (cứng)' AS Message;
END;
GO




USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_category_create]    Script Date: 9/24/2025 5:05:13 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_category_create]
(
    @CategoryName NVARCHAR(100),
    @Description  NVARCHAR(255)
)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Categories (CategoryName, [Description])
    VALUES (@CategoryName, @Description);

    SELECT '';
END
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_category_delete]    Script Date: 9/24/2025 5:05:31 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[sp_category_delete](
@CategoryID int)

as
begin
delete from Categories
where CategoryID = @CategoryID
select'';
end 
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_category_get_by_id]    Script Date: 9/24/2025 5:05:40 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[sp_category_get_by_id](@CategoryID int)
as
begin
select * from Categories where CategoryID = @CategoryID;
end;
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_category_search]    Script Date: 9/24/2025 5:05:48 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_category_search]
    @page_index   INT,
    @page_size    INT,
    @CategoryName NVARCHAR(100) = N'',
    @option       NVARCHAR(50)  = N'',   -- 'name_desc' hoặc rỗng/mặc định
    @CategoryID   INT           = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF (@option = N'name_desc')
    BEGIN
        SELECT CAST(COUNT(1) OVER() AS BIGINT) AS RecordCount,
               src.CategoryID, src.CategoryName, src.[Description]
        FROM (
            SELECT c.CategoryID, c.CategoryName, c.[Description]
            FROM dbo.Categories AS c
            WHERE (@CategoryID IS NULL OR c.CategoryID = @CategoryID)
              AND (@CategoryName = N'' OR c.CategoryName LIKE N'%' + @CategoryName + N'%')
        ) AS src
        ORDER BY src.CategoryName DESC
        OFFSET (@page_index - 1) * @page_size ROWS
        FETCH NEXT @page_size ROWS ONLY;
    END
    ELSE
    BEGIN
        SELECT CAST(COUNT(1) OVER() AS BIGINT) AS RecordCount,
               src.CategoryID, src.CategoryName, src.[Description]
        FROM (
            SELECT c.CategoryID, c.CategoryName, c.[Description]
            FROM dbo.Categories AS c
            WHERE (@CategoryID IS NULL OR c.CategoryID = @CategoryID)
              AND (@CategoryName = N'' OR c.CategoryName LIKE N'%' + @CategoryName + N'%')
        ) AS src
        ORDER BY src.CategoryName ASC
        OFFSET (@page_index - 1) * @page_size ROWS
        FETCH NEXT @page_size ROWS ONLY;
    END
END
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_category_update]    Script Date: 9/24/2025 5:05:58 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[sp_category_update](
@CategoryID int,
@CategoryName nvarchar(100),
@Description nvarchar(250))

as 
begin
update Categories set CategoryName = isnull(@CategoryName,CategoryName),
Description = isnull( @Description,Description)
where CategoryID = @CategoryID
select'';
end
GO