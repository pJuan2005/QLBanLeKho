﻿create database QLBanLeKho
use QLBanLeKho


drop database QLBanLeKho



CREATE TABLE AuditLogs (
    AuditID INT IDENTITY(1,1) PRIMARY KEY,  -- Khóa chính

    UserID INT NULL,                        -- Id người thực hiện
    Username VARCHAR(50) NULL,              -- Tên đăng nhập tại thời điểm thao tác
    FullName NVARCHAR(100) NULL,            -- Họ tên tại thời điểm thao tác

    Action NVARCHAR(200) NOT NULL,          -- Hành động: "Create Product", "Update Invoice"...
    EntityName NVARCHAR(100) NULL,          -- Tên bảng: "Products", "Invoices"...
    EntityID INT NULL,                      -- ID bản ghi bị tác động
    Operation NVARCHAR(20) NOT NULL,        -- CREATE / UPDATE / DELETE / LOGIN...

    Details NVARCHAR(MAX) NULL,             -- JSON chi tiết
    CreatedAt DATETIME2 NOT NULL 
        DEFAULT SYSDATETIME(),              -- Thời điểm ghi log

    CONSTRAINT FK_AuditLogs_Users 
        FOREIGN KEY (UserID) REFERENCES Users(UserID)
);




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
    Description NVARCHAR(255), -- Mô tả
	VATRate DECIMAL(5,2) NOT NULL DEFAULT 10.00
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
    ProductID INT IDENTITY(1,1) PRIMARY KEY,          -- Mã sản phẩm tự tăng
    SKU VARCHAR(50) NOT NULL UNIQUE,                  -- Mã SKU (bắt buộc, duy nhất)
    Barcode VARCHAR(50) NOT NULL UNIQUE,              -- Mã barcode (bắt buộc, duy nhất)
    ProductName NVARCHAR(100) NOT NULL,               -- Tên sản phẩm (bắt buộc)
    CategoryID INT NOT NULL,                          -- Mã loại hàng (bắt buộc)
    UnitPrice DECIMAL(18,2) DEFAULT 0,                          -- Giá
    Unit NVARCHAR(20) NULL,                                -- Đơn vị tính
    MinStock INT DEFAULT 0,                           -- Tồn kho tối thiểu
    Status NVARCHAR(20) DEFAULT 'Active',             -- Trạng thái
    ImageData VARBINARY(MAX) NULL,                    -- Hình ảnh
    VATRate DECIMAL(5,2) NULL,                             -- Thuế VAT
    Quantity INT DEFAULT 0,                           -- Số lượng tồn
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);


select * from Products




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
	NameProduct NVARCHAR(50),
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
    TotalAmount DECIMAL(18,2) DEFAULT 0, -- Tổng tiền
	UserID INT NOT NULL, -- Thêm cột mã nhân viên
	 BatchNo VARCHAR(50), -- Số lô
    FOREIGN KEY (POID) REFERENCES PurchaseOrders(POID) ON DELETE CASCADE,
	FOREIGN KEY (UserID) REFERENCES Users(UserID) -- Thiết lập khóa ngoại
);


CREATE TABLE GoodsReceiptDetails (
    ReceiptID INT, -- Mã phiếu nhập kho
    ProductID INT, -- Mã sản phẩm
	ProductName NVARCHAR(100) NOT NULL, -- Tên sản phẩm
    Quantity INT NOT NULL, -- Số lượng
    UnitPrice DECIMAL(18,2) NOT NULL, -- Đơn giá
    ExpiryDate DATETIME  NULL , -- Hạn dùng
    PRIMARY KEY (ReceiptID, ProductID),
    FOREIGN KEY (ReceiptID) REFERENCES GoodsReceipts(ReceiptID) ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);




CREATE TABLE Promotions (
    PromotionID INT IDENTITY(1,1) PRIMARY KEY, -- Mã khuyến mãi
	CategoryID INT NULL,
    PromotionName NVARCHAR(100) NOT NULL, -- Tên khuyến mãi
    Type NVARCHAR(20) NOT NULL, -- Loại giảm giá (Percent/Value)
    Value DECIMAL(18,2) NOT NULL, -- Giá trị giảm
    StartDate DATE NOT NULL, -- Ngày bắt đầu
    EndDate DATE NOT NULL, -- Ngày kết thúc
	FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
    
);


CREATE TABLE GoodsIssues (
    IssueID INT IDENTITY(1,1) PRIMARY KEY,		   -- Mã phiếu xuất kho								   
    IssueDate DATETIME NOT NULL DEFAULT GETDATE(), -- Ngày xuất kho
    UserID INT NOT NULL,                           -- Nhân viên thực hiện xuất kho
    TotalAmount DECIMAL(18,2) DEFAULT 0,           -- Tổng giá trị hàng xuất
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);



CREATE TABLE GoodsIssueDetails (
    IssueID INT NOT NULL,                          -- Mã phiếu xuất kho
    ProductID INT NOT NULL,                        -- Mã sản phẩm
	ProductName NVARCHAR(100) NOT NULL, -- Tên sản phẩm
    Quantity INT NOT NULL,                         -- Số lượng xuất
    UnitPrice DECIMAL(18,2) NOT NULL,
	BatchNo VARCHAR(50),-- Số lô xuất kho-- Đơn giá xuất
    FOREIGN KEY (IssueID) REFERENCES GoodsIssues(IssueID) ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

ALTER TABLE GoodsIssueDetails
DROP COLUMN BatchNo;


CREATE TABLE Sales (
    SaleID INT IDENTITY(1,1) PRIMARY KEY, -- Mã đơn bán hàng
    CustomerID INT, -- Mã khách hàng
    UserID INT NOT NULL, -- Mã nhân viên (người bán)
    SaleDate DATETIME NOT NULL, -- Ngày bán
    TotalAmount DECIMAL(18,2) DEFAULT 0, -- Tổng tiền
    VATAmount DECIMAL(18,2) DEFAULT 0, -- Thuế VAT   
    PaymentStatus NVARCHAR(20) DEFAULT 'Unpaid', -- Trạng thái thanh toán
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
   
);





CREATE TABLE SalesItems (
    SaleID INT, -- Mã đơn bán hàng
    ProductID INT, -- Mã sản phẩm
	 ProductName NVARCHAR(100) , -- Tên sản phẩm
    Quantity INT NOT NULL, -- Số lượng
    UnitPrice DECIMAL(18,2) NOT NULL, -- Đơn giá
    Discount DECIMAL(18,2) DEFAULT 0, -- Giảm giá
    PRIMARY KEY (SaleID, ProductID),
    FOREIGN KEY (SaleID) REFERENCES Sales(SaleID)  ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);





CREATE TABLE Returns (
    ReturnID INT IDENTITY(1,1) PRIMARY KEY,
    -- Loại trả hàng: 1 = trả từ khách hàng; 2 = trả về nhà cung cấp
    ReturnType TINYINT NULL,    
    -- Liên kết giao dịch gốc
    SaleID INT NULL,                -- bắt buộc nếu ReturnType = 1
    ReceiptID INT NULL,             -- bắt buộc nếu ReturnType = 2
    -- Liên kết master data
    CustomerID INT NULL,           
    SupplierID INT NULL,
    -- Snapshot thông tin khách/NCC tại thời điểm trả hàng
    PartnerName NVARCHAR(100),      -- tên khách hoặc nhà cung cấp
    PartnerPhone VARCHAR(20),
    ReturnDate DATETIME NOT NULL DEFAULT GETDATE(),
    Reason NVARCHAR(255),
    ProductID INT NOT NULL,
	ProductName NVARCHAR(100) NULL, -- Tên sản phẩm
    Quantity INT NOT NULL CHECK (Quantity > 0),
    UnitPrice DECIMAL(18,2) NOT NULL,      -- snapshot giá tại thời điểm trả
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    FOREIGN KEY (SaleID)      REFERENCES Sales(SaleID),
    FOREIGN KEY (ReceiptID)   REFERENCES GoodsReceipts(ReceiptID),
    FOREIGN KEY (CustomerID)  REFERENCES Customers(CustomerID),
    FOREIGN KEY (SupplierID)  REFERENCES Suppliers(SupplierID)
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
    PaymentID INT IDENTITY(1,1) PRIMARY KEY,
    SaleID INT NULL,                  -- Liên kết đến đơn bán
    CustomerID INT NULL,              -- Khách hàng trả tiền
	SupplierID INT NULL,
	ReceiptID INT NULL,
    Amount DECIMAL(18,2) NOT NULL,        -- Số tiền khách hàng sẽ thanh toán tại thời điểm đó
    PaymentDate DATE NOT NULL DEFAULT GETDATE(),
    Method NVARCHAR(30) NOT NULL,         -- Tiền mặt / Chuyển khoản / QR
    Description NVARCHAR(200) NOT NULL,       -- Ghi chú (vd: trả lần 1)
    FOREIGN KEY (SaleID) REFERENCES Sales(SaleID),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
	FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID),
	FOREIGN KEY (ReceiptID) REFERENCES GoodsReceipts(ReceiptID)
);


drop table StockCards

CREATE TABLE StockCards (
    StockID INT IDENTITY(1,1) PRIMARY KEY, -- Mã thẻ kho
    ProductID INT NOT NULL, -- Mã sản phẩm
	ProductName NVARCHAR(100) NOT NULL, -- Tên sản phẩm
    TransactionType NVARCHAR(10) NOT NULL, -- Loại giao dịch (IN/OUT)
    Quantity INT NOT NULL, -- Số lượng
    Balance INT NOT NULL, -- Tồn sau giao dịch 
    ReceiptID INT, -- Mã tham chiếu phiếu nhập kho
	IssueID INT, --Mã tham chiếu phiếu xuất kho
    TransactionDate DATETIME NOT NULL, -- Ngày giao dịch
	 SupplierID INT , -- Mã nhà cung cấp
	 BatchNo VARCHAR(50), -- Số lô
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
	FOREIGN KEY (ReceiptID) REFERENCES GoodsReceipts(ReceiptID),
	FOREIGN KEY (SupplierID) REFERENCES Suppliers (SupplierID),
	FOREIGN KEY (IssueID) REFERENCES GoodsIssues(IssueID)

);


select * from StockCards
---------------------------------------------------------------------------------------------------------------------------------


drop TABLE SystemSettings

CREATE TABLE SystemSettings (
	SettingID INT IDENTITY(1,1) PRIMARY KEY, 
    Setting NVARCHAR(100) ,
	Information NVARCHAR(100)
);

-- =============================================
-- Stored Procedure để TẠO MỚI một cài đặt
-- =============================================
select * from SystemSettings

CREATE PROCEDURE [dbo].[sp_system_setting_create]
(
    @Setting NVARCHAR(100),
    @Information NVARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO SystemSettings (Setting, Information)
    VALUES (@Setting, @Information);
    SELECT SCOPE_IDENTITY();
END
GO

-- =============================================
-- Stored Procedure để XÓA một cài đặt theo ID
-- =============================================
CREATE PROCEDURE [dbo].[sp_system_setting_delete]
(
    @SettingID INT
)
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM SystemSettings
    WHERE SettingID = @SettingID;
END
GO





CREATE PROCEDURE [dbo].[sp_system_setting_update]
(
    @SettingID INT,
    @Setting NVARCHAR(100),
    @Information NVARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE SystemSettings
    SET 
        Setting = @Setting,
        Information = @Information
    WHERE 
        SettingID = @SettingID;
END
GO



CREATE PROCEDURE [dbo].[sp_system_settings_get_all] @SettingID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT *
    FROM SystemSettings
	WHERE SettingID = @SettingID
END
GO


CREATE PROCEDURE [dbo].[sp_system_setting_search]
(
    @page_index  INT, 
    @page_size   INT,
    @SettingID   INT = NULL,
    @Setting     VARCHAR(100) = '',
    @Information NVARCHAR(100) = ''
)
AS
BEGIN
    DECLARE @RecordCount BIGINT;

    IF(@page_size <> 0)
    BEGIN
        SET NOCOUNT ON;

        SELECT 
            ROW_NUMBER() OVER (ORDER BY p.SettingID ASC) AS RowNumber,
			   p.SettingID,
               p.Setting,
               p.Information
        INTO #Results1
        FROM SystemSettings AS p
        WHERE (@SettingID IS NULL OR p.SettingID = @SettingID)
          AND (@Setting = '' OR p.Setting LIKE '%' + @Setting + '%')
          AND (@Information = '' OR p.Information LIKE N'%' + @Information + '%')

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

        SELECT 
            ROW_NUMBER() OVER (ORDER BY p.SettingID ASC) AS RowNumber,
		       p.SettingID,
               p.Setting,
               p.Information 
        INTO #Results2
        FROM SystemSettings AS p
        WHERE (@SettingID IS NULL OR p.SettingID = @SettingID)
          AND (@Setting = '' OR p.Setting LIKE '%' + @Setting + '%')
          AND (@Information = '' OR p.Information LIKE N'%' + @Information + '%')

        SELECT @RecordCount = COUNT(*) FROM #Results2;

        SELECT *, @RecordCount AS RecordCount
        FROM #Results2;

        DROP TABLE #Results2;
    END;
END;
GO


INSERT INTO SystemSettings (Setting,Information)
VALUES
(N'Address', N'38 tống duy tân'),
(N'Name', N'Hệ Thống Quản Lý Bán Lẻ & Kho'),
(N'Phonenumber', N'0941771437'),
(N'Email', N'a@gmail.com'),
(N'Currency', N'VND'),
(N'Currency', N'USD'),
(N'Currency', N'EUR'),
(N'Currency', N'JPY'),
(N'Currency', N'GBP'),
(N'Currency', N'CNY'),
(N'Time zone', N'UTC-12: Đường Quốc tế Thay Đổi Ngày'),
(N'Time zone', N'UTC-11: Samoa'),
(N'Time zone', N'UTC-10: Hawaii'),
(N'Time zone', N'UTC-9: Alaska'),
(N'Time zone', N'UTC-8: Thái Bình Dương (Canada, Mỹ)'),
(N'Time zone', N'UTC-7: Núi Rocky (Canada, Mỹ)'),
(N'Time zone', N'UTC-6: Trung Mỹ (Mexico, Canada, Mỹ)'),
(N'Time zone', N'UTC-5: Đông Bắc Mỹ (Canada, Mỹ)'),
(N'Time zone', N'UTC-4: Đông Nam Mỹ (Brazil, Argentina)'),
(N'Time zone', N'UTC-3: Đông Nam Mỹ (Brazil, Argentina)'),
(N'Time zone', N'UTC-2: Đại Tây Dương'),
(N'Time zone', N'UTC-1: Đại Tây Dương (Greenland)'),
(N'Time zone', N'UTC+0: Anh, Bồ Đào Nha, Ireland'),
(N'Time zone', N'UTC+1: Tây Âu (Pháp, Đức, Italy)'),
(N'Time zone', N'UTC+2: Trung Đông và Đông Âu'),
(N'Time zone', N'UTC+3: Nga, Trung Đông'),
(N'Time zone', N'UTC+4: Caucasus, Nga'),
(N'Time zone', N'UTC+5: Trung Á'),
(N'Time zone', N'UTC+6: Bangladesh, Siberia'),
(N'Time zone', N'UTC+7: Đông Nam Á'),
(N'Time zone', N'UTC+8: Trung Quốc, Đông Á'),
(N'Time zone', N'UTC+9: Nhật Bản, Hàn Quốc'),
(N'Time zone', N'UTC+10: Đông Úc'),
(N'Time zone', N'UTC+11: Tây Thái Bình Dương'),
(N'Time zone', N'UTC+12: Tân Zeeland, Fiji')



select * from SystemSettings






--------------------------------------------------------------------------------------------------------

drop PROCEDURE [dbo].[sp_system_settings_get_all]

-- USERS (15 bản ghi)
INSERT INTO Users (Username, PasswordHash, Role, FullName, Email, Phone)
VALUES
('admin', '123456', 'Admin', N'Nguyễn Văn A', 'admin1@shop.com', '0901111001'),
('thuNgan1', '123456', 'ThuNgan', N'Trần Thị B', 'thungan1@shop.com', '0901111002'),
('thuNgan2', '123456', 'ThuNgan', N'Nguyễn Văn C', 'thungan2@shop.com', '0901111003'),
('thuKho1', '123456', 'ThuKho', N'Lê Văn D', 'thukho1@shop.com', '0901111004'),
('thuKho2', '123456', 'ThuKho', N'Phạm Văn E', 'thukho2@shop.com', '0901111005'),
('keToan1', '123456', 'KeToan', N'Đặng Thị F', 'ketoan1@shop.com', '0901111006'),
('keToan2', '123456', 'KeToan', N'Ngô Văn G', 'ketoan2@shop.com', '0901111007'),
('user1', '123456', 'ThuNgan', N'Vũ Văn H', 'user1@shop.com', '0901111008'),
('user2', '123456', 'ThuKho', N'Đỗ Thị I', 'user2@shop.com', '0901111009'),
('user3', '123456', 'KeToan', N'Hoàng Văn J', 'user3@shop.com', '0901111010'),
('user4', '123456', 'Admin', N'Lưu Văn K', 'user4@shop.com', '0901111011'),
('user5', '123456', 'ThuNgan', N'Nguyễn Thị L', 'user5@shop.com', '0901111012'),
('user6', '123456', 'ThuKho', N'Phan Văn M', 'user6@shop.com', '0901111013'),
('user7', '123456', 'KeToan', N'Đoàn Thị N', 'user7@shop.com', '0901111014'),
('user8', '123456', 'Admin', N'Tạ Văn O', 'user8@shop.com', '0901111015');

-- CATEGORIES (15 bản ghi)
INSERT INTO Categories (CategoryName, Description,VATRate)
VALUES
(N'Giày Thể Thao', N'Các loại giày thể thao nam nữ',10),
(N'Sandal', N'Sandal thời trang',12),
(N'Dép', N'Dép đi trong nhà và ngoài trời',4),
(N'Giày Tây', N'Giày công sở nam',0),
(N'Giày Cao Gót', N'Giày cho nữ giới',10),
(N'Giày Boot', N'Giày mùa đông',17),
(N'Giày Sneaker', N'Giày phong cách trẻ trung',34),
(N'Giày Chạy Bộ', N'Giày cho vận động viên',22),
(N'Giày Leo Núi', N'Giày chuyên dụng leo núi',19),
(N'Giày Lười', N'Giày không cần buộc dây',6),
(N'Giày Tennis', N'Giày đánh tennis',2),
(N'Giày Golf', N'Giày chơi golf',40),
(N'Giày Bóng Đá', N'Giày đá bóng',0),
(N'Giày Bóng Rổ', N'Giày chơi bóng rổ',10),
(N'Giày Thời Trang', N'Giày phong cách cá nhân',10);


select * from Categories

-- SUPPLIERS (15 bản ghi)
INSERT INTO Suppliers (SupplierName, Address, Phone, Email)
VALUES
(N'Nhà Cung Cấp A', N'Hà Nội', '0912000001', 'nccA@shop.com'),
(N'Nhà Cung Cấp B', N'Hải Phòng', '0912000002', 'nccB@shop.com'),
(N'Nhà Cung Cấp C', N'Đà Nẵng', '0912000003', 'nccC@shop.com'),
(N'Nhà Cung Cấp D', N'TP HCM', '0912000004', 'nccD@shop.com'),
(N'Nhà Cung Cấp E', N'Cần Thơ', '0912000005', 'nccE@shop.com'),
(N'Nhà Cung Cấp F', N'Nam Định', '0912000006', 'nccF@shop.com'),
(N'Nhà Cung Cấp G', N'Ninh Bình', '0912000007', 'nccG@shop.com'),
(N'Nhà Cung Cấp H', N'Lào Cai', '0912000008', 'nccH@shop.com'),
(N'Nhà Cung Cấp I', N'Hà Giang', '0912000009', 'nccI@shop.com'),
(N'Nhà Cung Cấp J', N'Hưng Yên', '0912000010', 'nccJ@shop.com'),
(N'Nhà Cung Cấp K', N'Bắc Ninh', '0912000011', 'nccK@shop.com'),
(N'Nhà Cung Cấp L', N'Hà Nam', '0912000012', 'nccL@shop.com'),
(N'Nhà Cung Cấp M', N'Lạng Sơn', '0912000013', 'nccM@shop.com'),
(N'Nhà Cung Cấp N', N'Hòa Bình', '0912000014', 'nccN@shop.com'),
(N'Nhà Cung Cấp O', N'Vĩnh Phúc', '0912000015', 'nccO@shop.com');

-- CUSTOMERS (15 bản ghi)
INSERT INTO Customers (CustomerName, Phone, Email, Address, DebtLimit)
VALUES
(N'Khách Hàng 1', '0923000001', 'kh1@shop.com', N'Hà Nội', 1000000),
(N'Khách Hàng 2', '0923000002', 'kh2@shop.com', N'Hải Phòng', 2000000),
(N'Khách Hàng 3', '0923000003', 'kh3@shop.com', N'Đà Nẵng', 3000000),
(N'Khách Hàng 4', '0923000004', 'kh4@shop.com', N'TP HCM', 4000000),
(N'Khách Hàng 5', '0923000005', 'kh5@shop.com', N'Cần Thơ', 5000000),
(N'Khách Hàng 6', '0923000006', 'kh6@shop.com', N'Nam Định', 6000000),
(N'Khách Hàng 7', '0923000007', 'kh7@shop.com', N'Ninh Bình', 7000000),
(N'Khách Hàng 8', '0923000008', 'kh8@shop.com', N'Lào Cai', 8000000),
(N'Khách Hàng 9', '0923000009', 'kh9@shop.com', N'Hà Giang', 9000000),
(N'Khách Hàng 10', '0923000010', 'kh10@shop.com', N'Hưng Yên', 10000000),
(N'Khách Hàng 11', '0923000011', 'kh11@shop.com', N'Bắc Ninh', 11000000),
(N'Khách Hàng 12', '0923000012', 'kh12@shop.com', N'Hà Nam', 12000000),
(N'Khách Hàng 13', '0923000013', 'kh13@shop.com', N'Lạng Sơn', 13000000),
(N'Khách Hàng 14', '0923000014', 'kh14@shop.com', N'Hòa Bình', 14000000),
(N'Khách Hàng 15', '0923000015', 'kh15@shop.com', N'Vĩnh Phúc', 15000000);




INSERT INTO Products (SKU, Barcode, ProductName, CategoryID,Quantity,UnitPrice, Unit, MinStock, Status, ImageData, VATRate)
VALUES
('SKU001', 'BC001', N'Giày Sneaker Trắng', 1,4,0,  N'Đôi', 10, 'Active',NULL , 15.00),
('SKU002', 'BC002', N'Giày Sneaker Đen', 1,9,0,  N'Đôi', 10, 'Active',NULL , 10.00),
('SKU003', 'BC003', N'Giày Chạy Bộ Nam', 8,6,0,  N'Đôi',  5, 'Active',NULL , 20.00),
('SKU004', 'BC004', N'Giày Chạy Bộ Nữ', 8,1,0,  N'Đôi',  5, 'Active', NULL, 10.00),
('SKU005', 'BC005', N'Giày Tennis Trắng', 11,0,0, N'Đôi',  3, 'Active', NULL, 10.00),
('SKU006', 'BC006', N'Giày Bóng Đá Cỏ Tự Nhiên', 13,25,0,  N'Đôi',  7, 'Active',NULL, 10.00),
('SKU007', 'BC007', N'Giày Bóng Đá Cỏ Nhân Tạo', 13,6,0,  N'Đôi',  7, 'Active', NULL, 20.00),
('SKU008', 'BC008', N'Giày Bóng Rổ Cao Cổ', 14,18,0,  N'Đôi', 6, 'Active',NULL, 0),
('SKU009', 'BC009', N'Giày Golf Chống Thấm', 12,6,0,  N'Đôi',2, 'Active', NULL, 10.00),
('SKU010', 'BC010', N'Giày Tây Nam', 4, 25 ,0, N'Đôi', 4, 'Active', NULL, 10.00),
('SKU011', 'BC011', N'Giày Cao Gót Đen', 5, 16,0,  N'Đôi',3, 'Active', NULL, 0),
('SKU012', 'BC012', N'Giày Boot Da', 6,0,0,  N'Đôi',2, 'Active',NULL, 20.00),
('SKU013', 'BC013', N'Dép Lê Nam', 3,1,0,  N'Đôi',20, 'Active', NULL, 15.00),
('SKU014', 'BC014', N'Sandal Nữ Thời Trang', 2,40,0, N'Đôi',15, 'Active', NULL, 15.00),
('SKU015', 'BC015', N'Giày Lười Nam', 10, 21,0, N'Đôi', 8, 'Active', NULL, 0);


/* =========================
   1) PURCHASE ORDERS (15)
   ========================= */
INSERT INTO PurchaseOrders (SupplierID, OrderDate, TotalAmount, Status) VALUES
(1,  '2025-01-05', 0, N'Pending'),
(2,  '2025-01-06', 0, N'Completed'),
(3,  '2025-01-07', 0, N'Pending'),
(4,  '2025-01-08', 0, N'Completed'),
(5,  '2025-01-09', 0, N'Pending'),
(6,  '2025-01-10', 0, N'Completed'),
(7,  '2025-01-11', 0, N'Pending'),
(8,  '2025-01-12', 0, N'Completed'),
(9,  '2025-01-13', 0, N'Pending'),
(10, '2025-01-14', 0, N'Completed'),
(11, '2025-01-15', 0, N'Pending'),
(12, '2025-01-16', 0, N'Completed'),
(13, '2025-01-17', 0, N'Pending'),
(14, '2025-01-18', 0, N'Completed'),
(15, '2025-01-19', 0, N'Pending');


select *from PurchaseOrders





INSERT INTO PurchaseOrderDetails (POID, ProductID, NameProduct, Quantity, UnitPrice) VALUES
(1, 1,  N'Giày Sneaker Trắng',           20, 450000),
(2, 2,  N'Giày Sneaker Đen',             30, 470000),
(3, 3,  N'Giày Chạy Bộ Nam',             25, 520000),
(4, 4,  N'Giày Chạy Bộ Nữ',              18, 500000),
(5, 5,  N'Giày Tennis Trắng',            15, 530000),
(6, 6,  N'Giày Bóng Đá Cỏ Tự Nhiên',     40, 410000),
(7, 7,  N'Giày Bóng Đá Cỏ Nhân Tạo',     35, 420000),
(8, 8,  N'Giày Bóng Rổ Cao Cổ',          22, 650000),
(9, 9,  N'Giày Golf Chống Thấm',         12, 980000),
(10,10, N'Giày Tây Nam',                  30, 590000),
(11,11, N'Giày Cao Gót Đen',              28, 480000),
(12,12, N'Giày Boot Da',                  16, 880000),
(13,13, N'Dép Lê Nam',                    50, 120000),
(14,14, N'Sandal Nữ Thời Trang',          40, 220000),
(15,15, N'Giày Lười Nam',                 26, 540000);







INSERT INTO GoodsReceipts (POID, ReceiptDate, TotalAmount, UserID, BatchNo) VALUES
(1,  '2025-01-20', 0,  1,  'BCH001'),
(2,  '2025-01-21', 0,  2,  'BCH002'),
(3,  '2025-01-22', 0,  3,  'BCH003'),
(4,  '2025-01-23', 0,  4,  'BCH004'),
(5,  '2025-01-24', 0,  5,  'BCH005'),
(6,  '2025-01-25', 0,  6,  'BCH006'),
(7,  '2025-01-26', 0,  7,  'BCH007'),
(8,  '2025-01-27', 0,  8,  'BCH008'),
(9,  '2025-01-28', 0,  9,  'BCH009'),
(10, '2025-01-29', 0, 10,  'BCH010'),
(11, '2025-01-30', 0, 11,  'BCH011'),
(12, '2025-01-31', 0, 12,  'BCH012'),
(13, '2025-02-01', 0, 13,  'BCH013'),
(14, '2025-02-02', 0, 14,  'BCH014'),
(15, '2025-02-03', 0, 15,  'BCH015');






INSERT INTO GoodsReceiptDetails (ReceiptID, ProductID, ProductName, Quantity, UnitPrice, ExpiryDate) VALUES
(1,  1,  N'Giày Sneaker Trắng',           20, 450000, NULL),
(2,  2,  N'Giày Sneaker Đen',             30, 470000, NULL),
(3,  3,  N'Giày Chạy Bộ Nam',             25, 520000, NULL),
(4,  4,  N'Giày Chạy Bộ Nữ',              18, 500000, NULL),
(5,  5,  N'Giày Tennis Trắng',            15, 530000, NULL),
(6,  6,  N'Giày Bóng Đá Cỏ Tự Nhiên',     40, 410000, NULL),
(7,  7,  N'Giày Bóng Đá Cỏ Nhân Tạo',     35, 420000, NULL),
(8,  8,  N'Giày Bóng Rổ Cao Cổ',          22, 650000, NULL),
(9,  9,  N'Giày Golf Chống Thấm',         12, 980000, NULL),
(10, 10, N'Giày Tây Nam',                  30, 590000, NULL),
(11, 11, N'Giày Cao Gót Đen',              28, 480000, NULL),
(12, 12, N'Giày Boot Da',                  16, 880000, NULL),
(13, 13, N'Dép Lê Nam',                    50, 120000, NULL),
(14, 14, N'Sandal Nữ Thời Trang',          40, 220000, NULL),
(15, 15, N'Giày Lười Nam',                 26, 540000, NULL);







INSERT INTO Promotions (CategoryID, PromotionName, Type, Value, StartDate, EndDate) VALUES
(1,  N'Flash Sale Sneaker',           N'Percent', 10, '2025-02-05', '2025-02-10'),
(2,  N'Sandal 8/3',                   N'Percent', 15, '2025-03-01', '2025-03-10'),
(3,  N'Dép Cuối Tuần',                N'Value',   20000, '2025-02-15', '2025-02-20'),
(4,  N'Giày Tây Deal Tết',            N'Percent', 12, '2025-01-25', '2025-02-05'),
(5,  N'Cao Gót Vip',                  N'Percent', 20, '2025-02-14', '2025-02-20'),
(6,  N'Boot Đông Ấm',                 N'Value',   50000, '2025-01-01', '2025-01-31'),
(7,  N'Sneaker Trẻ',                  N'Percent', 5,  '2025-04-01', '2025-04-15'),
(8,  N'Running Day',                  N'Percent', 18, '2025-05-01', '2025-05-07'),
(9,  N'Leo Núi Pro',                  N'Value',   80000, '2025-06-01', '2025-06-15'),
(10, N'Lười Mà Sang',                 N'Percent', 7,  '2025-02-01', '2025-02-07'),
(11, N'Tennis Tháng 5',               N'Value',   30000, '2025-05-10', '2025-05-20'),
(12, N'Golf VIP',                     N'Percent', 10, '2025-07-01', '2025-07-10'),
(13, N'Bóng Đá Quốc Tế',              N'Percent', 12, '2025-06-05', '2025-06-12'),
(14, N'Bóng Rổ Rực Lửa',              N'Value',   40000, '2025-08-01', '2025-08-15'),
(NULL, N'Toàn Cửa Hàng - Sinh Nhật',  N'Percent', 5,  '2025-09-01', '2025-09-07');

/* =================
   6) GOODS ISSUES (15)
   ================= */
INSERT INTO GoodsIssues (IssueDate, UserID, TotalAmount) VALUES
('2025-02-10 10:00:00', 1,  0),
('2025-02-11 11:00:00', 2,  0),
('2025-02-12 12:00:00', 3,  0),
('2025-02-13 13:00:00', 4,  0),
('2025-02-14 14:00:00', 5,  0),
('2025-02-15 15:00:00', 6,  0),
('2025-02-16 16:00:00', 7,  0),
('2025-02-17 17:00:00', 8,  0),
('2025-02-18 18:00:00', 9,  0),
('2025-02-19 19:00:00',10,  0),
('2025-02-20 10:30:00',11,  0),
('2025-02-21 11:30:00',12,  0),
('2025-02-22 12:30:00',13,  0),
('2025-02-23 13:30:00',14,  0),
('2025-02-24 14:30:00',15,  0);

/* ==========================
   7) GOODS ISSUE DETAILS (15)
   (IssueID 1..15; ProductID 1..15)
   ========================== */
INSERT INTO GoodsIssueDetails (IssueID, ProductID, ProductName, Quantity, UnitPrice) VALUES
(1,  1,  N'Giày Sneaker Trắng',           2, 480000),
(2,  2,  N'Giày Sneaker Đen',             3, 495000),
(3,  3,  N'Giày Chạy Bộ Nam',             1, 560000),
(4,  4,  N'Giày Chạy Bộ Nữ',              2, 540000),
(5,  5,  N'Giày Tennis Trắng',            1, 560000),
(6,  6,  N'Giày Bóng Đá Cỏ Tự Nhiên',     4, 450000),
(7,  7,  N'Giày Bóng Đá Cỏ Nhân Tạo',     3, 460000),
(8,  8,  N'Giày Bóng Rổ Cao Cổ',          2, 700000),
(9,  9,  N'Giày Golf Chống Thấm',         1, 1050000),
(10, 10, N'Giày Tây Nam',                  3, 630000),
(11, 11, N'Giày Cao Gót Đen',              2, 520000),
(12, 12, N'Giày Boot Da',                  1, 920000),
(13, 13, N'Dép Lê Nam',                    5, 150000),
(14, 14, N'Sandal Nữ Thời Trang',          4, 250000),
(15, 15, N'Giày Lười Nam',                 2, 580000);

/* =========
   8) SALES (15)
   ========= */
INSERT INTO Sales (CustomerID, UserID, SaleDate, TotalAmount, VATAmount, PaymentStatus) VALUES
(1,  1,  '2025-03-01 09:00:00', 960000,   96000,  N'Paid'),
(2,  2,  '2025-03-01 10:00:00', 495000,   49500,  N'Paid'),
(3,  3,  '2025-03-02 11:00:00', 560000,   56000,  N'Unpaid'),
(4,  4,  '2025-03-02 12:00:00', 540000,   54000,  N'Paid'),
(5,  5,  '2025-03-03 13:00:00', 560000,   56000,  N'Unpaid'),
(6,  6,  '2025-03-03 14:00:00', 1800000, 180000,  N'Paid'),
(7,  7,  '2025-03-04 15:00:00', 1380000, 138000,  N'Partial'),
(8,  8,  '2025-03-04 16:00:00', 1400000, 140000,  N'Paid'),
(9,  9,  '2025-03-05 17:00:00', 1050000, 105000,  N'Paid'),
(10, 10, '2025-03-05 18:00:00', 1890000, 189000,  N'Partial'),
(11, 11, '2025-03-06 10:30:00', 1040000, 104000,  N'Paid'),
(12, 12, '2025-03-06 11:30:00', 920000,   92000,  N'Unpaid'),
(13, 13, '2025-03-07 12:30:00', 750000,   75000,  N'Paid'),
(14, 14, '2025-03-07 13:30:00', 1000000, 100000,  N'Paid'),
(15, 15, '2025-03-08 14:30:00', 1160000, 116000,  N'Unpaid');

/* ==================
   9) SALES ITEMS (15)
   (1 item mỗi đơn)
   ================== */
INSERT INTO SalesItems (SaleID, ProductID, ProductName, Quantity, UnitPrice, Discount) VALUES
(1,  1,  N'Giày Sneaker Trắng',           2, 480000, 0),
(2,  2,  N'Giày Sneaker Đen',             1, 495000, 0),
(3,  3,  N'Giày Chạy Bộ Nam',             1, 560000, 0),
(4,  4,  N'Giày Chạy Bộ Nữ',              1, 540000, 0),
(5,  5,  N'Giày Tennis Trắng',            1, 560000, 0),
(6,  6,  N'Giày Bóng Đá Cỏ Tự Nhiên',     4, 450000, 0),
(7,  7,  N'Giày Bóng Đá Cỏ Nhân Tạo',     3, 460000, 0),
(8,  8,  N'Giày Bóng Rổ Cao Cổ',          2, 700000, 0),
(9,  9,  N'Giày Golf Chống Thấm',         1, 1050000, 0),
(10, 10, N'Giày Tây Nam',                  3, 630000, 0),
(11, 11, N'Giày Cao Gót Đen',              2, 520000, 0),
(12, 12, N'Giày Boot Da',                  1, 920000, 0),
(13, 13, N'Dép Lê Nam',                    5, 150000, 0),
(14, 14, N'Sandal Nữ Thời Trang',          4, 250000, 0),
(15, 15, N'Giày Lười Nam',                 2, 580000, 0);

/* ==============
   10) RETURNS (15)
   (Một số trả từ Sales, một số trả NCC theo Receipt)
   ============== */
INSERT INTO Returns (SaleID, CustomerID, ReturnDate, Reason, SupplierID, ReceiptID) VALUES
(1,  1,  '2025-03-02', N'Không vừa size',                 NULL, NULL),
(2,  2,  '2025-03-02', N'Lỗi keo nhẹ',                    NULL, NULL),
(3,  3,  '2025-03-03', N'Đổi mẫu',                        NULL, NULL),
(4,  4,  '2025-03-03', N'Màu không hợp',                  NULL, NULL),
(5,  5,  '2025-03-04', N'Đế trơn',                        NULL, NULL),
(6,  6,  '2025-03-04', N'Hàng lỗi đường may',            NULL, NULL),
(7,  7,  '2025-03-05', N'Khách đổi size',                 NULL, NULL),
(8,  8,  '2025-03-05', N'Gót cứng',                       NULL, NULL),
(9,  9,  '2025-03-06', N'Trái kỳ vọng',                   NULL, NULL),
(10, 10, '2025-03-06', N'Giao nhầm mẫu',                  NULL, NULL),
(NULL, NULL, '2025-02-02', N'Trả nhà cung cấp - lỗi lô',  1, 1),
(NULL, NULL, '2025-02-03', N'Trả NCC - giày tróc da',     2, 2),
(NULL, NULL, '2025-02-04', N'Trả NCC - lỗi keo',          3, 3),
(NULL, NULL, '2025-02-05', N'Trả NCC - hư form',          4, 4),
(NULL, NULL, '2025-02-06', N'Trả NCC - sai nhãn',         5, 5);

/* =============
   11) INVOICES (15)
   (mỗi Sale có 1 Invoice)
   ============= */
INSERT INTO Invoices (SaleID, InvoiceNo, InvoiceDate, TotalAmount, VATAmount) VALUES
(1,  'INV0001', '2025-03-01', 960000,   96000),
(2,  'INV0002', '2025-03-01', 495000,   49500),
(3,  'INV0003', '2025-03-02', 560000,   56000),
(4,  'INV0004', '2025-03-02', 540000,   54000),
(5,  'INV0005', '2025-03-03', 560000,   56000),
(6,  'INV0006', '2025-03-03', 1800000, 180000),
(7,  'INV0007', '2025-03-04', 1380000, 138000),
(8,  'INV0008', '2025-03-04', 1400000, 140000),
(9,  'INV0009', '2025-03-05', 1050000, 105000),
(10, 'INV0010', '2025-03-05', 1890000, 189000),
(11, 'INV0011', '2025-03-06', 1040000, 104000),
(12, 'INV0012', '2025-03-06', 920000,   92000),
(13, 'INV0013', '2025-03-07', 750000,   75000),
(14, 'INV0014', '2025-03-07', 1000000, 100000),
(15, 'INV0015', '2025-03-08', 1160000, 116000);

/* =============
   12) PAYMENTS (15)
   (10 bản ghi cho Sales, 5 bản ghi thanh toán NCC theo Receipt)
   ============= */
INSERT INTO Payments (SaleID, CustomerID, SupplierID, ReceiptID, Amount, PaymentDate, Method, Description) VALUES
(1,  1,  NULL, NULL, 960000,  '2025-03-01', N'Tiền mặt',     N'Thanh toán đủ'),
(2,  2,  NULL, NULL, 495000,  '2025-03-01', N'Chuyển khoản', N'Thanh toán đủ'),
(3,  3,  NULL, NULL, 200000,  '2025-03-02', N'Tiền mặt',     N'Trả lần 1'),
(4,  4,  NULL, NULL, 540000,  '2025-03-02', N'QR',           N'Thanh toán đủ'),
(5,  5,  NULL, NULL, 200000,  '2025-03-03', N'Chuyển khoản', N'Trả lần 1'),
(6,  6,  NULL, NULL, 1800000, '2025-03-03', N'Chuyển khoản', N'Thanh toán đủ'),
(7,  7,  NULL, NULL, 800000,  '2025-03-04', N'QR',           N'Trả lần 1'),
(8,  8,  NULL, NULL, 1400000, '2025-03-04', N'Tiền mặt',     N'Thanh toán đủ'),
(9,  9,  NULL, NULL, 1050000, '2025-03-05', N'Chuyển khoản', N'Thanh toán đủ'),
(10, 10, NULL, NULL, 900000,  '2025-03-05', N'QR',           N'Trả lần 1'),
(NULL, NULL, 1, 1,  5000000, '2025-02-05', N'Chuyển khoản', N'Thanh toán NCC lô 1'),
(NULL, NULL, 2, 2,  7000000, '2025-02-06', N'Chuyển khoản', N'Thanh toán NCC lô 2'),
(NULL, NULL, 3, 3,  6000000, '2025-02-07', N'Tiền mặt',     N'Thanh toán NCC lô 3'),
(NULL, NULL, 4, 4,  4500000, '2025-02-08', N'QR',           N'Thanh toán NCC lô 4'),
(NULL, NULL, 5, 5,  5200000, '2025-02-09', N'Chuyển khoản', N'Thanh toán NCC lô 5');

/* =================
   13) STOCK CARDS (15)
   (tham chiếu ReceiptID 1..8 cho IN và IssueID 1..7 cho OUT)
   ================= */
INSERT INTO StockCards (ProductID, ProductName, TransactionType, Quantity, Balance, ReceiptID, IssueID, TransactionDate, SupplierID, BatchNo) VALUES
(1,  N'Giày Sneaker Trắng',           N'IN',  20,  24, 1, NULL, '2025-01-20 10:00:00', 1,  'BCH001'),
(2,  N'Giày Sneaker Đen',             N'IN',  30,  39, 2, NULL, '2025-01-21 10:00:00', 2,  'BCH002'),
(3,  N'Giày Chạy Bộ Nam',             N'IN',  25,  31, 3, NULL, '2025-01-22 10:00:00', 3,  'BCH003'),
(4,  N'Giày Chạy Bộ Nữ',              N'IN',  18,  19, 4, NULL, '2025-01-23 10:00:00', 4,  'BCH004'),
(5,  N'Giày Tennis Trắng',            N'IN',  15,  15, 5, NULL, '2025-01-24 10:00:00', 5,  'BCH005'),
(6,  N'Giày Bóng Đá Cỏ Tự Nhiên',     N'IN',  40,  65, 6, NULL, '2025-01-25 10:00:00', 6,  'BCH006'),
(7,  N'Giày Bóng Đá Cỏ Nhân Tạo',     N'IN',  35,  41, 7, NULL, '2025-01-26 10:00:00', 7,  'BCH007'),
(8,  N'Giày Bóng Rổ Cao Cổ',          N'IN',  22,  40, 8, NULL, '2025-01-27 10:00:00', 8,  'BCH008'),
(1,  N'Giày Sneaker Trắng',           N'OUT',  2,  22, NULL, 1,  '2025-02-10 10:00:00', NULL, NULL),
(2,  N'Giày Sneaker Đen',             N'OUT',  3,  36, NULL, 2,  '2025-02-11 11:00:00', NULL, NULL),
(3,  N'Giày Chạy Bộ Nam',             N'OUT',  1,  30, NULL, 3,  '2025-02-12 12:00:00', NULL, NULL),
(4,  N'Giày Chạy Bộ Nữ',              N'OUT',  2,  17, NULL, 4,  '2025-02-13 13:00:00', NULL, NULL),
(8,  N'Giày Bóng Rổ Cao Cổ',          N'OUT',  2,  38, NULL, 8,  '2025-02-17 17:00:00', NULL, NULL),
(10, N'Giày Tây Nam',                 N'OUT',  3,  22, NULL, 10, '2025-02-19 19:00:00', NULL, NULL),
(13, N'Dép Lê Nam',                    N'OUT',  5,  46, NULL, 13, '2025-02-22 12:30:00', NULL, NULL);




EXEC sp_product_create 
  @SKU='gggg', 
  @Barcode='gggg', 
  @ProductName=N'Giày test', 
  @CategoryID=5



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
SELECT * FROM GoodsIssues;
SELECT * FROM GoodsIssueDetails
SELECT * FROM Returns;
SELECT * FROM Invoices;
SELECT * FROM Payments;
SELECT * FROM StockCards;
select * from SystemSettings

DELETE FROM products;

-- 1. Xóa chi tiết bán hàng trước
DELETE FROM SalesItems;
DELETE FROM Returns;
DELETE FROM Invoices;
DELETE FROM Payments;

-- 2. Xóa chi tiết nhập hàng
DELETE FROM GoodsReceiptDetails;
DELETE FROM PurchaseOrderDetails;

-- 3. Xóa chứng từ tổng
DELETE FROM GoodsReceipts;
DELETE FROM PurchaseOrders;

-- 4. Xóa tồn kho và khuyến mãi
DELETE FROM StockCards;
DELETE FROM Promotions;

-- 5. Xóa danh mục chính
DELETE FROM Products;
DELETE FROM Categories;
DELETE FROM Suppliers;
DELETE FROM Customers;
DELETE FROM Sales;

-- 6. Xóa người dùng cuối cùng
DELETE FROM Users;


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


DROP PROCEDURE [dbo].[sp_product_create]


CREATE PROCEDURE [dbo].[sp_product_create]
(
    @SKU         VARCHAR(50),
    @Barcode     VARCHAR(50) = NULL,
    @ProductName NVARCHAR(100),
    @CategoryID  INT = NULL,
    @UnitPrice   DECIMAL(18,2) = 0,
    @Unit        NVARCHAR(20) = NULL,
    @MinStock    INT = 0,
    @Status      NVARCHAR(20) = 'Active',
    @VATRate     DECIMAL(5,2) = NULL,
    @Quantity    INT = 0,
    @ImageData   VARBINARY(MAX) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- 🧩 Kiểm tra SKU trùng
        IF EXISTS (SELECT 1 FROM Products WHERE SKU = @SKU)
        BEGIN
            RAISERROR(N'SKU "%s" đã tồn tại trong hệ thống.', 16, 1, @SKU);
            RETURN;
        END

        -- 🧩 Kiểm tra Barcode trùng
        IF (@Barcode IS NOT NULL AND @Barcode <> '')
           AND EXISTS (SELECT 1 FROM Products WHERE Barcode = @Barcode)
        BEGIN
            RAISERROR(N'Barcode "%s" đã tồn tại trong hệ thống.', 16, 1, @Barcode);
            RETURN;
        END

        -- 🧩 Đảm bảo ProductName, SKU, CategoryID có giá trị
        IF (@ProductName IS NULL OR LTRIM(RTRIM(@ProductName)) = '')
        BEGIN
            RAISERROR(N'ProductName không được để trống.', 16, 1);
            RETURN;
        END

        IF (@SKU IS NULL OR LTRIM(RTRIM(@SKU)) = '')
        BEGIN
            RAISERROR(N'SKU không được để trống.', 16, 1);
            RETURN;
        END

        IF (@CategoryID IS NULL)
        BEGIN
            RAISERROR(N'CategoryID không được để trống.', 16, 1);
            RETURN;
        END

        -- ✅ Gán giá trị mặc định nếu rỗng
        SET @UnitPrice = ISNULL(@UnitPrice, 0);
        SET @Unit = ISNULL(@Unit, N'');
        SET @MinStock = ISNULL(@MinStock, 0);
        SET @Status = ISNULL(@Status, N'Active');
        SET @Quantity = ISNULL(@Quantity, 0);

        -- ✅ Thêm dữ liệu
        INSERT INTO Products
        (
            SKU,
            Barcode,
            ProductName,
            CategoryID,
            UnitPrice,
            Unit,
            MinStock,
            Status,
            ImageData,
            VATRate,
            Quantity
        )
        VALUES
        (
            @SKU,
            @Barcode,
            @ProductName,
            @CategoryID,
            @UnitPrice,
            @Unit,
            @MinStock,
            @Status,
            @ImageData,
            @VATRate,
            @Quantity
        );

        -- Trả về ID sản phẩm mới
        SELECT SCOPE_IDENTITY() AS NewProductID;
    END TRY
    BEGIN CATCH
        DECLARE @Err NVARCHAR(4000);
        SELECT @Err = ERROR_MESSAGE();
        RAISERROR(@Err, 16, 1);
    END CATCH
END;
GO




drop PROCEDURE [dbo].[sp_product_update]

CREATE OR ALTER PROCEDURE [dbo].[sp_product_update]
(
    @ProductID   INT,
    @SKU         VARCHAR(50) = NULL,
    @Barcode     VARCHAR(50) = NULL,
    @ProductName NVARCHAR(100) = NULL,
    @CategoryID  INT = NULL,
    @UnitPrice   DECIMAL(18,2) = NULL,
    @Unit        NVARCHAR(20) = NULL,
    @MinStock    INT = NULL,
    @Status      NVARCHAR(20) = NULL,
    @ImageData   VARBINARY(MAX) = NULL,
    @VATRate     DECIMAL(5,2) = NULL,
    @Quantity    INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Products WHERE ProductID = @ProductID)
            THROW 50010, N'ProductID không tồn tại.', 1;

        IF @CategoryID IS NOT NULL
            IF NOT EXISTS (SELECT 1 FROM Categories WHERE CategoryID = @CategoryID)
                THROW 50011, N'CategoryID không tồn tại.', 1;

        IF @SKU IS NOT NULL AND EXISTS (SELECT 1 FROM Products WHERE SKU = @SKU AND ProductID <> @ProductID)
            THROW 50012, N'SKU đã tồn tại cho sản phẩm khác.', 1;

        IF @Barcode IS NOT NULL AND EXISTS (SELECT 1 FROM Products WHERE Barcode = @Barcode AND ProductID <> @ProductID)
            THROW 50013, N'Barcode đã tồn tại cho sản phẩm khác.', 1;

        IF @UnitPrice IS NOT NULL AND @UnitPrice < 0  THROW 50014, N'UnitPrice không được âm.', 1;
        IF @MinStock IS NOT NULL AND @MinStock < 0    THROW 50015, N'MinStock không được âm.', 1;
        IF @Quantity IS NOT NULL AND @Quantity < 0    THROW 50016, N'Quantity không được âm.', 1;
        IF @VATRate IS NOT NULL AND (@VATRate < 0 OR @VATRate > 100)
            THROW 50017, N'VATRate phải trong khoảng 0–100.', 1;

        UPDATE Products
        SET
            SKU         = COALESCE(@SKU,        SKU),
            Barcode     = COALESCE(@Barcode,    Barcode),
            ProductName = COALESCE(@ProductName,ProductName),
            CategoryID  = COALESCE(@CategoryID, CategoryID),
            UnitPrice   = COALESCE(@UnitPrice,  UnitPrice),
            Unit        = COALESCE(@Unit,       Unit),
            MinStock    = COALESCE(@MinStock,   MinStock),
            Status      = COALESCE(@Status,     Status),
            ImageData   = COALESCE(@ImageData,  ImageData),
            VATRate     = COALESCE(@VATRate,    VATRate),
            Quantity    = COALESCE(@Quantity,   Quantity)
        WHERE ProductID = @ProductID;

        SELECT 'OK' AS Message;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO


select * from Products


drop PROCEDURE [dbo].[sp_product_search]




drop PROCEDURE [dbo].[sp_product_search]

select *from Products

CREATE PROCEDURE [dbo].[sp_product_search]
(
    @page_index  INT, 
    @page_size   INT,
    @ProductID   INT = NULL,
    @SKU         VARCHAR(50) = '',
	@Barcode     VARCHAR(50) = '',
    @ProductName NVARCHAR(100) = '',
    @CategoryID  INT = NULL,
    @Status      NVARCHAR(20) = ''
)
AS
BEGIN
    DECLARE @RecordCount BIGINT;

    IF(@page_size <> 0)
    BEGIN
        SET NOCOUNT ON;

        SELECT 
            ROW_NUMBER() OVER (ORDER BY p.ProductID ASC) AS RowNumber,
			   p.ProductID,
               p.SKU,
               p.Barcode,
               p.ProductName,
               p.CategoryID,
			   p.UnitPrice,
               p.Unit,
               p.MinStock,
               p.Status,
			   p.ImageData,
			   p.VATRate,
			   p.Quantity 
        INTO #Results1
        FROM Products AS p
        WHERE (@ProductID IS NULL OR p.ProductID = @ProductID)
          AND (@SKU = '' OR p.SKU LIKE '%' + @SKU + '%')
		  AND (@Barcode = '' OR p.Barcode LIKE '%' + @Barcode + '%')
          AND (@ProductName = '' OR p.ProductName LIKE N'%' + @ProductName + '%')
          AND (@CategoryID IS NULL OR p.CategoryID = @CategoryID)
          AND (@Status = '' OR p.Status = @Status)


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

        SELECT 
            ROW_NUMBER() OVER (ORDER BY p.ProductID ASC) AS RowNumber,
		       p.ProductID,
               p.SKU,
               p.Barcode,
               p.ProductName,
               p.CategoryID,
			   p.UnitPrice,
               p.Unit,
               p.MinStock,
               p.Status,
			   p.ImageData,
			   p.VATRate,
			   p.Quantity 
        INTO #Results2
        FROM Products AS p
        WHERE (@ProductID IS NULL OR p.ProductID = @ProductID)
          AND (@SKU = '' OR p.SKU LIKE '%' + @SKU + '%')
		  AND (@Barcode = '' OR p.Barcode LIKE '%' + @Barcode + '%')
          AND (@ProductName = '' OR p.ProductName LIKE N'%' + @ProductName + '%')
          AND (@CategoryID IS NULL OR p.CategoryID = @CategoryID)
          AND (@Status = '' OR p.Status = @Status);

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
	DELETE FROM GoodsIssueDetails WHERE ProductID = @ProductID;

    -- Cuối cùng xóa trong bảng Products
    DELETE FROM Products
    WHERE ProductID = @ProductID;

    SELECT 'Xóa sản phẩm thành công (cứng)' AS Message;
END;
GO

select * from Products
EXEC sp_product_delete @ProductID = 16;
DROP PROCEDURE [dbo].[sp_product_delete];





CREATE TRIGGER dbo.trg_Products_Insert_VATRate
ON dbo.Products
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE p
    SET p.VATRate = c.VATRate
    FROM dbo.Products   AS p
    JOIN inserted       AS i ON p.ProductID = i.ProductID
    JOIN dbo.Categories AS c ON i.CategoryID = c.CategoryID
    WHERE p.VATRate IS NULL; -- ✅ cập nhật khi giá trị trên bảng Products đang NULL
END;
GO



---------------------------------------------------------------------------------------------

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



drop PROCEDURE [dbo].[sp_payment_create]

CREATE PROCEDURE [dbo].[sp_payment_create]
(
    @SaleID INT = NULL,
    @CustomerID INT = NULL,
	@SupplierID INT = NULL,
	@ReceiptID INT = NULL,
    @Amount DECIMAL(18,2),
    @PaymentDate DATE,
    @Method NVARCHAR(30),
	@Description NVARCHAR(200)
)
AS
BEGIN
	SET NOCOUNT ON;
    INSERT INTO Payments
    (
        SaleID,
        CustomerID,
		SupplierID,
		ReceiptID,
        Amount,
        PaymentDate,
        Method,
		Description
    )
    VALUES
    (
        @SaleID,
        @CustomerID,
		@SupplierID,
		@ReceiptID,
        @Amount,
        @PaymentDate,
        @Method,
		@Description
    );

    SELECT SCOPE_IDENTITY() AS NewProductID;
END;
GO

SELECT * FROM Payments;


CREATE PROCEDURE [dbo].[sp_payment_update]
(
	@PaymentID   INT = NULL,    
    @SaleID   INT = NULL,
    @CustomerID  INT = NULL,
	@SupplierID INT = NULL,
	@ReceiptID INT = NULL,
    @Amount      DECIMAL(18,2),
    @PaymentDate DATE,
    @Method      NVARCHAR(30),
	@Description NVARCHAR(200)
)
AS
BEGIN
    UPDATE Payments
    SET
        SaleID = IIF(@SaleID IS NULL, SaleID, @SaleID),
        CustomerID = IIF(@CustomerID IS NULL, CustomerID, @CustomerID),
		SupplierID = IIF(@SupplierID IS NULL, SupplierID, @SupplierID),
		ReceiptID = IIF(@ReceiptID IS NULL, ReceiptID, @ReceiptID),
        Amount     = IIF(@Amount IS NULL, Amount, @Amount),
        PaymentDate= IIF(@PaymentDate IS NULL, PaymentDate, @PaymentDate),
        Method     = IIF(@Method IS NULL, Method, @Method),
		Description = IIF(@Description IS NULL, Description, @Description)
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
	@SupplierID	 INT = NULL,
	@ReceiptID	 INT = NULL,
    @PaymentDate DATETIME = NULL,       
	@FromDate    DATETIME = NULL,
    @ToDate      DATETIME = NULL,
    @Method      NVARCHAR(20) = '',
	@SaleID		 INT
)
AS
BEGIN
    DECLARE @RecordCount BIGINT;

    IF(@page_size <> 0)
    BEGIN
        SET NOCOUNT ON;

        SELECT ROW_NUMBER() OVER (ORDER BY p.PaymentID ASC) AS RowNumber,
               p.PaymentID,
               p.CustomerID,
			   p.SupplierID,
			   p.ReceiptID,
               p.SaleID,
               p.Amount,
               p.PaymentDate,
               p.Method,
			   p.Description
        INTO #Results1
        FROM Payments AS p
        WHERE (@PaymentID IS NULL OR p.PaymentID = @PaymentID)
          AND (@CustomerID IS NULL OR p.CustomerID = @CustomerID)
          AND (@SaleID IS NULL OR p.SaleID = @SaleID)
		  AND (@ReceiptID IS NULL OR p.ReceiptID = @ReceiptID)
		  AND (@SupplierID IS NULL OR p.SupplierID = @SupplierID)
          AND (@Method = '' OR p.Method LIKE N'%' + @Method + '%')
		  AND (@FromDate IS NULL OR p.PaymentDate >= @FromDate)
          AND (@ToDate IS NULL OR p.PaymentDate <= @ToDate);

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

        SELECT ROW_NUMBER() OVER (ORDER BY p.PaymentID ASC) AS RowNumber,
               p.PaymentID,
               p.CustomerID,
               p.SaleID,
			   p.SupplierID,
			   p.ReceiptID,
               p.Amount,
               p.PaymentDate,
               p.Method,
			   p.Description
        INTO #Results2
        FROM Payments AS p
        WHERE (@PaymentID IS NULL OR p.PaymentID = @PaymentID)
          AND (@CustomerID IS NULL OR p.CustomerID = @CustomerID)
          AND (@SaleID IS NULL OR p.SaleID = @SaleID)
		  AND (@ReceiptID IS NULL OR p.ReceiptID = @ReceiptID)
		  AND (@SupplierID IS NULL OR p.SupplierID = @SupplierID)
          AND (@Method = '' OR p.Method LIKE N'%' + @Method + '%')
		  AND (@FromDate IS NULL OR p.PaymentDate >= @FromDate)
          AND (@ToDate IS NULL OR p.PaymentDate <= @ToDate);

        SELECT @RecordCount = COUNT(*) FROM #Results2;

        SELECT *, @RecordCount AS RecordCount
        FROM #Results2;

        DROP TABLE #Results2;
    END;
END;
GO

SELECT * 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Payments';





CREATE PROCEDURE [dbo].[sp_payment_delete]
    @PaymentID INT
AS
BEGIN
    SET NOCOUNT ON;


    DELETE FROM Payments
    WHERE PaymentID = @PaymentID;

    -- Trả về thông báo
    SELECT 'Xóa payment thành công (cứng)' AS Message;
END;
GO


select * from Payments




-- =============================================
-- Lấy thẻ kho theo ID
-- =============================================

CREATE PROCEDURE [dbo].[sp_stockcard_get_by_id]
    @StockID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM StockCards
    WHERE StockID = @StockID;
END;
GO



DROP PROCEDURE [sp_stockcard_get_by_id]
-- =============================================
-- Thêm mới thẻ kho
-- =============================================
CREATE PROCEDURE [dbo].[sp_stockcard_create]
(
    @ProductID       INT,
    @TransactionType NVARCHAR(10),
    @Quantity        INT,
    @Balance         INT,
    @ReceiptID       INT = NULL,
    @IssueID         INT = NULL,
    @SupplierID      INT = NULL,
    @BatchNo         VARCHAR(50) = NULL,
    @TransactionDate DATETIME
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ProductName NVARCHAR(100);

    -- Lấy ProductName từ bảng Products
    SELECT @ProductName = ProductName
    FROM Products
    WHERE ProductID = @ProductID;

    IF (@ProductName IS NULL)
    BEGIN
        RAISERROR('ProductID không tồn tại trong bảng Products', 16, 1);
        RETURN;
    END

    INSERT INTO StockCards
    (
        ProductID,
        ProductName,
        TransactionType,
        Quantity,
        Balance,
        ReceiptID,
        IssueID,
        SupplierID,
        BatchNo,
        TransactionDate
    )
    VALUES
    (
        @ProductID,
        @ProductName,
        @TransactionType,
        @Quantity,
        @Balance,
        @ReceiptID,
        @IssueID,
        @SupplierID,
        @BatchNo,
        @TransactionDate
    );

    SELECT SCOPE_IDENTITY() AS NewStockID;
END;
GO
SELECT * FROM Products;
SELECT * FROM Payments;
SELECT * FROM StockCards;
-- =============================================
-- Cập nhật thẻ kho
-- =============================================
CREATE PROCEDURE [dbo].[sp_stockcard_update]
(
    @StockID         INT,
    @ProductID       INT = NULL,
    @TransactionType NVARCHAR(10) = NULL,
    @Quantity        INT = NULL,
    @Balance         INT = NULL,
    @ReceiptID       INT = NULL,
    @IssueID         INT = NULL,
    @SupplierID      INT = NULL,
    @BatchNo         VARCHAR(50) = NULL,
    @TransactionDate DATETIME = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ProductName NVARCHAR(100);

    IF (@ProductID IS NOT NULL)
    BEGIN
        SELECT @ProductName = ProductName FROM Products WHERE ProductID = @ProductID;

        IF (@ProductName IS NULL)
        BEGIN
            RAISERROR('ProductID không tồn tại trong bảng Products', 16, 1);
            RETURN;
        END
    END

    UPDATE StockCards
    SET
        ProductID       = ISNULL(@ProductID, ProductID),
        ProductName     = ISNULL(@ProductName, ProductName),
        TransactionType = ISNULL(@TransactionType, TransactionType),
        Quantity        = ISNULL(@Quantity, Quantity),
        Balance         = ISNULL(@Balance, Balance),
        ReceiptID       = ISNULL(@ReceiptID, ReceiptID),
        IssueID         = ISNULL(@IssueID, IssueID),
        SupplierID      = ISNULL(@SupplierID, SupplierID),
        BatchNo         = ISNULL(@BatchNo, BatchNo),
        TransactionDate = ISNULL(@TransactionDate, TransactionDate)
    WHERE StockID = @StockID;

    -- ✔ TRẢ VỀ RECORD ĐÃ UPDATE
    SELECT '';
END;
GO





DROP PROCEDURE [sp_stockcard_delete]
-- =============================================
-- Xóa thẻ kho (cứng)
-- =============================================

CREATE PROCEDURE [dbo].[sp_stockcard_delete]
(
    @StockID INT
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra ID có tồn tại không
    IF NOT EXISTS (SELECT 1 FROM StockCards WHERE StockID = @StockID)
    BEGIN
        SELECT 0 AS Result; -- Không tồn tại
        RETURN;
    END

    -- Xóa
    DELETE FROM StockCards WHERE StockID = @StockID;

    SELECT 1 AS Result; -- Thành công
END;
GO




EXEC sp_stockcard_delete @StockID = 12;


DROP  PROCEDURE [dbo].[sp_stockcard_search]
-- =============================================
-- Tìm kiếm & phân trang thẻ kho
-- =============================================
CREATE PROCEDURE [dbo].[sp_stockcard_search]
(
    @page_index      INT,
    @page_size       INT,
    @StockID         INT = NULL,
    @ProductID       INT = NULL,
	@ProductName     NVARCHAR(100) = '',
    @TransactionType NVARCHAR(10) = '',
    @Balance         INT = NULL,
    @ReceiptID       INT = NULL,
    @IssueID         INT = NULL,
    @SupplierID      INT = NULL,
    @BatchNo         VARCHAR(50) = '',
    @FromDate        DATETIME = NULL,
    @ToDate          DATETIME = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RecordCount BIGINT;

    SELECT 
        ROW_NUMBER() OVER (ORDER BY sc.StockID DESC) AS RowNumber,
        sc.*
    INTO #Temp
    FROM StockCards sc
    WHERE (@StockID IS NULL OR sc.StockID = @StockID)
      AND (@ProductID IS NULL OR sc.ProductID = @ProductID)
	  AND (@ProductName = '' OR sc.ProductName LIKE '%' + @ProductName + '%')
      AND (@TransactionType = '' OR sc.TransactionType LIKE '%' + @TransactionType + '%')
      AND (@ReceiptID IS NULL OR sc.ReceiptID = @ReceiptID)
      AND (@IssueID IS NULL OR sc.IssueID = @IssueID)
      AND (@SupplierID IS NULL OR sc.SupplierID = @SupplierID)
      AND (@BatchNo = '' OR sc.BatchNo LIKE '%' + @BatchNo + '%')
      AND (@Balance IS NULL OR sc.Balance = @Balance)
      AND (@FromDate IS NULL OR sc.TransactionDate >= @FromDate)
      AND (@ToDate IS NULL OR sc.TransactionDate <= @ToDate)

    SELECT @RecordCount = COUNT(*) FROM #Temp;

    SELECT *, @RecordCount AS RecordCount
    FROM #Temp
    WHERE RowNumber BETWEEN (@page_index - 1) * @page_size + 1
                        AND (@page_index * @page_size)
       OR @page_size = -1;

    DROP TABLE #Temp;
END;
GO





-- =============================================
-- Báo cáo doanh thu & lợi nhuận gộp
-- =============================================

DROP PROCEDURE [dbo].[sp_report_revenue]

CREATE PROCEDURE sp_report_revenue
(
    @FromDate DATE,
    @ToDate   DATE,
    @Option   NVARCHAR(10) -- 'DAY' | 'MONTH'
)
AS
BEGIN
    SET NOCOUNT ON;

    IF @Option = 'DAY'
    BEGIN
        SELECT 
            CAST(s.SaleDate AS DATE) AS [Date],
            SUM(si.Quantity * (si.UnitPrice - si.Discount)) AS Revenue,
            SUM(si.Quantity * (si.UnitPrice - si.Discount) - ISNULL(grd.UnitPrice,0) * si.Quantity) AS GrossProfit
        FROM Sales s
        INNER JOIN SalesItems si ON s.SaleID = si.SaleID
        LEFT JOIN (
            SELECT ProductID, AVG(UnitPrice) AS UnitPrice
            FROM GoodsReceiptDetails
            GROUP BY ProductID
        ) grd ON si.ProductID = grd.ProductID
        WHERE CAST(s.SaleDate AS DATE) BETWEEN @FromDate AND @ToDate
        GROUP BY CAST(s.SaleDate AS DATE)
        ORDER BY [Date];
    END

    ELSE IF @Option = 'MONTH'
    BEGIN
        SELECT 
            FORMAT(s.SaleDate, 'yyyy-MM') AS [Date],
            SUM(si.Quantity * (si.UnitPrice - si.Discount)) AS Revenue,
            SUM(si.Quantity * (si.UnitPrice - si.Discount) - ISNULL(grd.UnitPrice,0) * si.Quantity) AS GrossProfit
        FROM Sales s
        INNER JOIN SalesItems si ON s.SaleID = si.SaleID
        LEFT JOIN (
            SELECT ProductID, AVG(UnitPrice) AS UnitPrice
            FROM GoodsReceiptDetails
            GROUP BY ProductID
        ) grd ON si.ProductID = grd.ProductID
        WHERE CAST(s.SaleDate AS DATE) BETWEEN @FromDate AND @ToDate
        GROUP BY FORMAT(s.SaleDate, 'yyyy-MM')
        ORDER BY [Date];
    END
END;






EXEC sp_report_revenue 
    @FromDate = '2025-02-01', 
    @ToDate   = '2025-02-28', 
    @Option   = 'DAY';



-- =============================================
-- Báo cáo nhập / xuất
-- =============================================
drop PROCEDURE [dbo].[sp_report_import_export]

--2
CREATE  PROCEDURE [dbo].[sp_report_import_export] -- Dùng CREATE OR ALTER để có thể chạy lại mà không cần xóa SP cũ
(
    @FromDate DATETIME,
    @ToDate DATETIME
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ToDateEnd DATETIME = DATEADD(DAY, 1, CAST(@ToDate AS DATE));

    SELECT 
        d.Date, -- FIX: Đổi từ d.DateValue thành d.Date
        ISNULL(SUM(d.ImportQty), 0) AS ImportQty,
        ISNULL(SUM(d.ExportQty), 0) AS ExportQty
    FROM
    (
        -- Nhập kho
        SELECT 
            CONVERT(DATE, pn.ReceiptDate) AS Date, -- FIX: Đổi alias từ DateValue thành Date
            SUM(ct.Quantity) AS ImportQty, 
            0 AS ExportQty
        FROM GoodsReceipts pn
        INNER JOIN GoodsReceiptDetails ct ON pn.ReceiptID = ct.ReceiptID
        WHERE pn.ReceiptDate >= @FromDate AND pn.ReceiptDate < @ToDateEnd
        GROUP BY CONVERT(DATE, pn.ReceiptDate)

        UNION ALL

        -- Xuất kho (bán hàng)
        SELECT 
            CONVERT(DATE, s.SaleDate) AS Date, -- FIX: Đổi alias từ DateValue thành Date
            0 AS ImportQty, 
            SUM(si.Quantity) AS ExportQty
        FROM Sales s
        INNER JOIN SalesItems si ON s.SaleID = si.SaleID
        WHERE s.SaleDate >= @FromDate AND s.SaleDate < @ToDateEnd
        GROUP BY CONVERT(DATE, s.SaleDate)
    ) d
    GROUP BY d.Date -- FIX: Đổi từ d.DateValue thành d.Date
    ORDER BY d.Date; -- FIX: Đổi từ d.DateValue thành d.Date
END;
GO




-- =============================================
-- Báo cáo tồn kho & tuổi hàng
-- =============================================
drop PROCEDURE [dbo].[sp_report_stock]


CREATE PROCEDURE [dbo].[sp_report_stock]
AS
BEGIN
    SET NOCOUNT ON;

    -- CTE để tính toán tồn kho hiện tại từ bảng StockCards
    WITH StockCalculations AS (
        SELECT
            ProductID,
            SUM(CASE WHEN TransactionType = 'IN' THEN Quantity ELSE -Quantity END) AS CalculatedStock
        FROM StockCards
        GROUP BY ProductID
    ),
    -- CTE để tìm ngày nhập hàng đầu tiên (lô hàng cũ nhất)
    OldestReceiptDate AS (
        SELECT
            grd.ProductID,
            MIN(gr.ReceiptDate) AS FirstReceiptDate
        FROM GoodsReceipts gr
        INNER JOIN GoodsReceiptDetails grd ON gr.ReceiptID = grd.ReceiptID
        GROUP BY grd.ProductID
    )
    
    -- Truy vấn chính để tạo báo cáo
    SELECT 
        p.ProductID,
        p.SKU,
        p.ProductName,
        p.MinStock,
        ISNULL(sc.CalculatedStock, 0) AS CurrentStock,
        -- Tính tuổi của lô hàng cũ nhất còn tồn
        ISNULL(DATEDIFF(DAY, ord.FirstReceiptDate, GETDATE()), 0) AS AgeInDays
    FROM 
        Products p
    -- Join với CTE tồn kho
    LEFT JOIN 
        StockCalculations sc ON p.ProductID = sc.ProductID
    -- Join với CTE ngày nhập cũ nhất
    LEFT JOIN 
        OldestReceiptDate ord ON p.ProductID = ord.ProductID
    ORDER BY 
        p.ProductName;

END;
GO






-- =============================================
-- Lấy trả hàngtheo ID
-- =============================================
CREATE PROCEDURE [dbo].[sp_return_get_by_id]
    @ReturnID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM Returns
    WHERE ReturnID = @ReturnID;
END;
GO


select * from Returns


-- =============================================
-- tạo return
-- =============================================
CREATE PROCEDURE [dbo].[sp_return_create]
(
    @SaleID INT = NULL,
    @CustomerID INT = NULL,
	@ReceiptID INT = NULL,
    @SupplierID INT = NULL,
    @ReturnDate DATE,
    @Reason NVARCHAR(255)
)
AS
BEGIN
	SET NOCOUNT ON;
    INSERT INTO Returns
    (
        SaleID,
        CustomerID,
		SupplierID,
		ReceiptID,
		ReturnDate,
        Reason
    )
    VALUES
    (
        @SaleID,
        @CustomerID,
		@SupplierID,
		@ReceiptID,
		@ReturnDate,
        @Reason
    );

    SELECT SCOPE_IDENTITY() AS NewReturnID;
END;
GO





-- =============================================
-- cập nhật return
-- =============================================
CREATE PROCEDURE [dbo].[sp_return_update]
(
	@ReturnID INT,
	@SaleID INT = NULL,
    @CustomerID INT = NULL,
	@SupplierID INT = NULL,
    @ReceiptID INT = NULL,
    @ReturnDate DATE,
    @Reason NVARCHAR(255)
)
AS
BEGIN
    UPDATE Returns
    SET
        SaleID = IIF(@SaleID IS NULL, SaleID, @SaleID ),
        CustomerID = IIF(@CustomerID IS NULL, CustomerID, @CustomerID),
		ReceiptID = IIF(@ReceiptID IS NULL, ReceiptID, @ReceiptID),
        SupplierID = IIF(@SupplierID IS NULL, SupplierID, @SupplierID),
        ReturnDate= IIF(@ReturnDate IS NULL, ReturnDate, @ReturnDate),
        Reason     = IIF(@Reason IS NULL, Reason, @Reason)
    WHERE ReturnID = @ReturnID;

    SELECT '';
END;
GO



drop PROCEDURE [dbo].[sp_return_search]

-- =============================================
-- tìm kiếm return
-- =============================================
CREATE PROCEDURE [dbo].[sp_return_search]
(
    @page_index  INT, 
    @page_size   INT,
    @ReturnID    INT = NULL,
    @SaleID      INT = NULL,
    @CustomerID  INT = NULL,
	@ReceiptID     INT = NULL,
    @SupplierID  INT = NULL,
    @FromDate    DATETIME = NULL,
    @ToDate      DATETIME = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RecordCount BIGINT;

    IF (@page_size <> 0)
    BEGIN
        SELECT 
            ROW_NUMBER() OVER (ORDER BY r.ReturnID DESC) AS RowNumber,
            r.ReturnID,
            r.SaleID,
            r.CustomerID,
			r.ReceiptID,
			r.SupplierID,
            r.ReturnDate,
            r.Reason
        INTO #Results1
        FROM Returns AS r
        WHERE (@ReturnID IS NULL OR r.ReturnID = @ReturnID)
          AND (@SaleID IS NULL OR r.SaleID = @SaleID)
          AND (@CustomerID IS NULL OR r.CustomerID = @CustomerID)
		  AND (@ReceiptID IS NULL OR r.ReceiptID = @ReceiptID)
          AND (@SupplierID IS NULL OR r.SupplierID = @SupplierID)
          AND (@FromDate IS NULL OR r.ReturnDate >= @FromDate)
          AND (@ToDate IS NULL OR r.ReturnDate <= @ToDate);

        SELECT @RecordCount = COUNT(*) FROM #Results1;

        SELECT 
            *, 
            @RecordCount AS RecordCount
        FROM #Results1
        WHERE RowNumber BETWEEN (@page_index - 1) * @page_size + 1 
                            AND ((@page_index - 1) * @page_size + @page_size);

        DROP TABLE #Results1;
    END
    ELSE
    BEGIN
        -- Nếu không phân trang, trả toàn bộ kết quả
        SELECT 
            ROW_NUMBER() OVER (ORDER BY r.ReturnID DESC) AS RowNumber,
            r.ReturnID,
            r.SaleID,
            r.CustomerID,
			r.ReceiptID,
			r.SupplierID,
            r.ReturnDate,
            r.Reason
        INTO #Results2
        FROM Returns AS r
        WHERE (@ReturnID IS NULL OR r.ReturnID = @ReturnID)
          AND (@SaleID IS NULL OR r.SaleID = @SaleID)
          AND (@CustomerID IS NULL OR r.CustomerID = @CustomerID)
		  AND (@ReceiptID IS NULL OR r.ReceiptID = @ReceiptID)
          AND (@SupplierID IS NULL OR r.SupplierID = @SupplierID)
          AND (@FromDate IS NULL OR r.ReturnDate >= @FromDate)
          AND (@ToDate IS NULL OR r.ReturnDate <= @ToDate);

        SELECT @RecordCount = COUNT(*) FROM #Results2;

        SELECT *, @RecordCount AS RecordCount FROM #Results2;

        DROP TABLE #Results2;
    END
END;
GO


select * from Payments



-- =============================================
-- xóa return
-- =============================================

CREATE PROCEDURE [dbo].[sp_return_delete]
    @ReturnID INT
AS
BEGIN
    SET NOCOUNT ON;


    DELETE FROM Returns
    WHERE ReturnID = @ReturnID;

    -- Trả về thông báo
    SELECT 'Xóa payment thành công (cứng)' AS Message;
END;
GO


drop PROCEDURE [dbo].[sp_return_delete]






select * from Products




-- =============================================
-- chuẩn
-- =============================================

USE [QLBanLeKho]
GO


create procedure [dbo].[sp_user_update]
(@UserId int,
@Username varchar(50),
@Password varchar(255),
@Role nvarchar(20),
@FullName nvarchar(100),
@Email nvarchar(100),
@Phone varchar(20)
)
as begin
update[Users]set Username = @Username, PasswordHash = @Password,Role = @Role,FullName=@FullName,Email =@Email,Phone=@Phone
where UserID = @UserId
select ''
end
GO


USE [QLBanLeKho]
GO



CREATE   PROCEDURE [dbo].[sp_user_search1]
(
    @pageIndex int,
    @pageSize int,
    @fullname nvarchar(100),
    @username varchar(50)
)
AS
BEGIN
    DECLARE @RecordCount bigint;

    IF (@pageSize <> 0)
    BEGIN
        SET NOCOUNT ON;

        SELECT (ROW_NUMBER() OVER (ORDER BY u.FullName ASC)) AS RowNumber,
               u.UserID,
               u.Username,
               u.PasswordHash,
               u.Role,
               u.FullName,
               u.Email,
               u.Phone
        INTO #Results1
        FROM [Users] AS u
        WHERE (u.Username <> 'Admin')
          AND ((@fullname = '') OR (u.FullName LIKE '%' + @fullname + '%'))
          AND ((@username = '') OR (u.Username = @username));

        SELECT @RecordCount = COUNT(*) FROM #Results1;

        SELECT *,
               @RecordCount AS RecordCount
        FROM #Results1
        WHERE RowNumber BETWEEN (@pageIndex - 1) * @pageSize + 1
                             AND (((@pageIndex - 1) * @pageSize + 1) + @pageSize) - 1
           OR @pageIndex = -1;

        DROP TABLE #Results1;
    END
    ELSE
    BEGIN
        SET NOCOUNT ON;

        SELECT (ROW_NUMBER() OVER (ORDER BY u.FullName ASC)) AS RowNumber,
               u.UserID,
               u.Username,
               u.PasswordHash,
               u.Role,
               u.FullName,
               u.Email,
               u.Phone
        INTO #Results2
        FROM [Users] AS u
        WHERE (u.Username <> 'Admin')
          AND ((@fullname = '') OR (u.FullName LIKE '%' + @fullname + '%'))
          AND ((@username = '') OR (u.Username = @username));

        SELECT @RecordCount = COUNT(*) FROM #Results2;

        SELECT *,
               @RecordCount AS RecordCount
        FROM #Results2;

        DROP TABLE #Results2;
    END
END
GO





USE [QLBanLeKho]
GO



create procedure [dbo].[sp_user_get_by_username_password](@username varchar(50), @password varchar(255))
as
begin
select [UserID],
Username,
PasswordHash,
Role,
FullName,
Email,
Phone
from Users where UserName = @username and PasswordHash = @password
end
GO


USE [QLBanLeKho]
GO



create procedure [dbo].[sp_user_get_by_id](@UserId int)
as
begin 
select [UserID],
Username,
PasswordHash,
Role,
FullName,
Email,
Phone
From [Users] where [UserID] = @UserId
end
GO


USE [QLBanLeKho]
GO



create procedure [dbo].[sp_user_delete](@UserId int)
as
begin delete from [Users] where UserID = @UserId
select ''
end
GO


USE [QLBanLeKho]
GO



create procedure [dbo].[sp_user_create](
@Username varchar(50),
@Password varchar(255),
@Role nvarchar(20),
@FullName nvarchar(100),
@Email nvarchar(100),
@Phone varchar(20)
)
as begin
set nocount on
insert into Users (Username,PasswordHash,Role,FullName,Email,Phone)
values (@Username,@Password,@Role,@FullName,@Email,@Phone)
select cast (SCOPE_IDENTITY()as int) as NewId
end
GO


USE [QLBanLeKho]
GO





USE [QLBanLeKho]
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


create procedure [dbo].[sp_category_get_by_id](@CategoryID int)
as
begin
select * from Categories where CategoryID = @CategoryID;
end;
GO


USE [QLBanLeKho]
GO



USE [QLBanLeKho]
GO

<<<<<<< HEAD
/****** Object:  StoredProcedure [dbo].[sp_category_search]    Script Date: 11/6/2025 3:56:25 PM ******/
=======
USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_category_search]    Script Date: 11/9/2025 9:43:05 PM ******/
>>>>>>> dev
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- CREATE OR ALTER cho tiện cập nhật nhiều lần
CREATE   PROCEDURE [dbo].[sp_category_search]
    @page_index   INT,
    @page_size    INT,

    -- Lọc theo tên/mô tả (để trống = không lọc)
    @CategoryName NVARCHAR(100) = N'',

    -- Lọc theo VAT:
    --  - nếu truyền @vat_exact thì ưu tiên lọc đúng bằng
    --  - nếu không, có thể truyền @vat_from / @vat_to để lọc theo khoảng
    @vat_exact    DECIMAL(5,2) = NULL,
    @vat_from     DECIMAL(5,2) = NULL,
    @vat_to       DECIMAL(5,2) = NULL,

    -- Tuỳ chọn sắp xếp ('' | 'name_desc')
    @option       NVARCHAR(50)  = N'',

    -- Lọc chính xác theo ID (null = bỏ qua)
    @CategoryID   INT           = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Chuẩn hoá tham số trang
    IF (@page_index IS NULL OR @page_index < 1) SET @page_index = 1;
    IF (@page_size  IS NULL OR @page_size  < 1) SET @page_size  = 10;

    ;WITH src AS
    (
        SELECT
            c.CategoryID,
            c.CategoryName,
            c.[Description],
            c.VATRate
        FROM dbo.Categories AS c
        WHERE
            -- lọc theo ID (nếu có)
            (@CategoryID IS NULL OR c.CategoryID = @CategoryID)
            -- lọc theo tên/mô tả (nếu có)
            AND (
                  @CategoryName = N''
               OR c.CategoryName LIKE N'%'+@CategoryName+N'%'
               OR c.[Description] LIKE N'%'+@CategoryName+N'%'
            )
            -- lọc theo VAT: ưu tiên @vat_exact, nếu không dùng khoảng
            AND (
                  @vat_exact IS NULL
                  OR c.VATRate = @vat_exact
                )
            AND (
                  @vat_exact IS NOT NULL
                  OR @vat_from IS NULL OR c.VATRate >= @vat_from
                )
            AND (
                  @vat_exact IS NOT NULL
                  OR @vat_to   IS NULL OR c.VATRate <= @vat_to
                )
    )
    SELECT
        CAST(COUNT(1) OVER() AS BIGINT) AS RecordCount,
        CategoryID,
        CategoryName,
        [Description],
        VATRate
    FROM src
    ORDER BY
        -- nếu option = 'name_desc' thì sắp xếp theo tên giảm dần
        CASE WHEN @option = N'name_desc' THEN NULL ELSE CategoryID END ASC,
        CASE WHEN @option = N'name_desc' THEN CategoryName END DESC,
        CategoryID ASC
    OFFSET (@page_index - 1) * @page_size ROWS
    FETCH NEXT @page_size ROWS ONLY;
END
GO

USE [QLBanLeKho]
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






CREATE TABLE Returns (
    ReturnID INT IDENTITY(1,1) PRIMARY KEY,
    -- Loại trả hàng: 1 = trả từ khách hàng; 2 = trả về nhà cung cấp
    ReturnType TINYINT NULL,    
    -- Liên kết giao dịch gốc
    SaleID INT NULL,                -- bắt buộc nếu ReturnType = 1
    ReceiptID INT NULL,             -- bắt buộc nếu ReturnType = 2
    -- Liên kết master data
    CustomerID INT NULL,           
    SupplierID INT NULL,
    -- Snapshot thông tin khách/NCC tại thời điểm trả hàng
    PartnerName NVARCHAR(100),      -- tên khách hoặc nhà cung cấp
    PartnerPhone VARCHAR(20),
    ReturnDate DATETIME NOT NULL DEFAULT GETDATE(),
    Reason NVARCHAR(255),
    ProductID INT NOT NULL,
	ProductName NVARCHAR(100) NULL, -- Tên sản phẩm
    Quantity INT NOT NULL CHECK (Quantity > 0),
    UnitPrice DECIMAL(18,2) NOT NULL,      -- snapshot giá tại thời điểm trả
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    FOREIGN KEY (SaleID)      REFERENCES Sales(SaleID),
    FOREIGN KEY (ReceiptID)   REFERENCES GoodsReceipts(ReceiptID),
    FOREIGN KEY (CustomerID)  REFERENCES Customers(CustomerID),
    FOREIGN KEY (SupplierID)  REFERENCES Suppliers(SupplierID)
);

drop table Returns




CREATE PROCEDURE [dbo].[sp_return_get_by_id]
(
    @ReturnID INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM Returns
    WHERE ReturnID = @ReturnID;
END;
GO




select * from Products



CREATE PROCEDURE [dbo].[sp_return_create]
(
    @ReturnType TINYINT,        
    @PartnerPhone VARCHAR(20),  

    @SaleID INT = NULL,
    @ReceiptID INT = NULL,

    @ProductID INT = NULL,   -- CHO PHÉP NULL ĐỂ KIỂM TRA
    @Quantity INT = NULL,     -- NẾU NULL → SET = 0

    @ReturnDate DATETIME,
    @Reason NVARCHAR(255)
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @CustomerID INT = NULL,
        @SupplierID INT = NULL,
        @PartnerName NVARCHAR(100) = NULL,
        @UnitPrice DECIMAL(18,2),
        @ProductName NVARCHAR(100);

    -----------------------------------------
    -- 1. VALIDATE PRODUCTID
    -----------------------------------------
    IF (@ProductID IS NULL)
    BEGIN
        RAISERROR(N'ProductID bắt buộc không được NULL', 16, 1);
        RETURN;
    END

    -----------------------------------------
    -- 2. XỬ LÝ Quantity = NULL → SET = 0
    -----------------------------------------
    IF (@Quantity IS NULL)
    BEGIN
        RAISERROR(N'Quantity số lượng phải lớn hơn 0', 16, 1);
        RETURN;
    END

    -----------------------------------------
    -- 3. LẤY THÔNG TIN SẢN PHẨM
    -----------------------------------------
    SELECT 
        @UnitPrice = UnitPrice,
        @ProductName = ProductName
    FROM Products
    WHERE ProductID = @ProductID;

    IF (@UnitPrice IS NULL OR @ProductName IS NULL)
    BEGIN
        RAISERROR(N'ProductID không tồn tại trong bảng Products', 16, 1);
        RETURN;
    END

    -----------------------------------------
    -- 4. RETURN TYPE 1 → KHÁCH TRẢ HÀNG
    -----------------------------------------
    IF (@ReturnType = 1)
    BEGIN
        IF (@SaleID IS NULL)
        BEGIN
            RAISERROR(N'SaleID bắt buộc khi ReturnType = 1', 16, 1);
            RETURN;
        END


		IF NOT EXISTS (SELECT 1 FROM Sales WHERE SaleID = @SaleID)
		BEGIN
			RAISERROR(N'SaleID không tồn tại trong bảng Sales', 16, 1);
			RETURN;
		END


        IF (@ReceiptID IS NOT NULL)
        BEGIN
            RAISERROR(N'ReceiptID phải NULL khi ReturnType = 1', 16, 1);
            RETURN;
        END

        SELECT TOP 1
            @CustomerID = CustomerID,
            @PartnerName = CustomerName
        FROM Customers
        WHERE Phone = @PartnerPhone;

        IF (@CustomerID IS NULL)
        BEGIN
            RAISERROR(N'Số điện thoại khách hàng không tồn tại', 16, 1);
            RETURN;
        END
    END
    -----------------------------------------
    -- 5. RETURN TYPE 2 → NHÀ CUNG CẤP
    -----------------------------------------
    ELSE IF (@ReturnType = 2)
    BEGIN
        IF (@ReceiptID IS NULL)
        BEGIN
            RAISERROR(N'ReceiptID bắt buộc khi ReturnType = 2', 16, 1);
            RETURN;
        END



		IF NOT EXISTS (SELECT 1 FROM GoodsReceipts WHERE ReceiptID = @ReceiptID)
		BEGIN
			RAISERROR(N'ReceiptID không tồn tại trong bảng GoodsReceipts', 16, 1);
			RETURN;
		END



        IF (@SaleID IS NOT NULL)
        BEGIN
            RAISERROR(N'SaleID phải NULL khi ReturnType = 2', 16, 1);
            RETURN;
        END

        SELECT TOP 1
            @SupplierID = SupplierID,
            @PartnerName = SupplierName
        FROM Suppliers
        WHERE Phone = @PartnerPhone;

        IF (@SupplierID IS NULL)
        BEGIN
            RAISERROR(N'Số điện thoại nhà cung cấp không tồn tại', 16, 1);
            RETURN;
        END
    END
    ELSE
    BEGIN
        RAISERROR(N'ReturnType không hợp lệ (1 = khách hàng, 2 = nhà cung cấp)', 16, 1);
        RETURN;
    END


    -----------------------------------------
    -- 6. INSERT DỮ LIỆU
    -----------------------------------------
    INSERT INTO Returns
    (
        ReturnType, SaleID, ReceiptID,
        CustomerID, SupplierID,
        PartnerName, PartnerPhone,
        ProductID, ProductName, Quantity, UnitPrice,
        ReturnDate, Reason
    )
    VALUES
    (
        @ReturnType, @SaleID, @ReceiptID,
        @CustomerID, @SupplierID,
        @PartnerName, @PartnerPhone,
        @ProductID, @ProductName, @Quantity, @UnitPrice,
        @ReturnDate, @Reason
    );

    SELECT SCOPE_IDENTITY() AS NewReturnID;
END;
GO









CREATE PROCEDURE [dbo].[sp_return_update]
(
    @ReturnID INT,
    @ReturnType TINYINT,

    @SaleID INT = NULL,
    @ReceiptID INT = NULL,

    @PartnerPhone VARCHAR(20) = NULL,
    @ReturnDate DATETIME = NULL,
    @Reason NVARCHAR(255) = NULL,

    @ProductID INT = NULL,
    @Quantity INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @CustomerID INT = NULL,
        @SupplierID INT = NULL,
        @PartnerName NVARCHAR(100) = NULL,
        @UnitPrice DECIMAL(18,2),
        @ProductName NVARCHAR(100);

    -----------------------------------------
    -- 1. KIỂM TRA RETURN TỒN TẠI
    -----------------------------------------
    IF NOT EXISTS (SELECT 1 FROM Returns WHERE ReturnID = @ReturnID)
    BEGIN
        RAISERROR(N'ReturnID không tồn tại', 16, 1);
        RETURN;
    END

    -----------------------------------------
    -- 2. LẤY GIÁ SẢN PHẨM NẾU ĐỔI PRODUCTID
    -----------------------------------------
    IF (@ProductID IS NOT NULL)
    BEGIN
        SELECT 
            @UnitPrice = UnitPrice,
            @ProductName = ProductName
        FROM Products
        WHERE ProductID = @ProductID;

        IF (@UnitPrice IS NULL)
        BEGIN
            RAISERROR(N'ProductID không hợp lệ', 16, 1);
            RETURN;
        END
    END

    -----------------------------------------
    -- 3. VALIDATION THEO RETURN TYPE
    -----------------------------------------

    ------------------------------------------------
    -- CASE 1: RETURN TYPE = 1 (KHÁCH TRẢ HÀNG)
    ------------------------------------------------
    IF (@ReturnType = 1)
    BEGIN
        -- SaleID phải có + ReceiptID phải NULL
        IF (@SaleID IS NULL)
        BEGIN
            RAISERROR(N'SaleID bắt buộc khi ReturnType = 1', 16, 1);
            RETURN;
        END


		IF NOT EXISTS (SELECT 1 FROM Sales WHERE SaleID = @SaleID)
		BEGIN
			RAISERROR(N'SaleID không tồn tại trong bảng Sales', 16, 1);
			RETURN;
		END

        IF (@ReceiptID IS NOT NULL)
        BEGIN
            RAISERROR(N'ReceiptID phải NULL khi ReturnType = 1', 16, 1);
            RETURN;
        END

        -- Nếu có truyền SĐT → lấy CustomerID
        IF (@PartnerPhone IS NOT NULL)
        BEGIN
            SELECT TOP 1
                @CustomerID = CustomerID,
                @PartnerName = CustomerName
            FROM Customers
            WHERE Phone = @PartnerPhone;

            IF (@CustomerID IS NULL)
            BEGIN
                RAISERROR(N'Số điện thoại khách hàng không tồn tại', 16, 1);
                RETURN;
            END
        END

        -- 🔥 BẮT BUỘC CustomerID phải có (theo yêu cầu của bạn)
        IF (@CustomerID IS NULL)
        BEGIN
            -- lấy CustomerID hiện tại trong bảng (nếu không đổi)
            SELECT @CustomerID = CustomerID FROM Returns WHERE ReturnID = @ReturnID;

            IF (@CustomerID IS NULL)
            BEGIN
                RAISERROR(N'CustomerID bắt buộc phải có khi ReturnType = 1', 16, 1);
                RETURN;
            END
        END

        -- Bắt buộc SupplierID NULL
        SET @SupplierID = NULL;
    END

    ------------------------------------------------
    -- CASE 2: RETURN TYPE = 2 (TRẢ NHÀ CUNG CẤP)
    ------------------------------------------------
    ELSE IF (@ReturnType = 2)
    BEGIN
        -- ReceiptID phải có + SaleID phải NULL
        IF (@ReceiptID IS NULL)
        BEGIN
            RAISERROR(N'ReceiptID bắt buộc khi ReturnType = 2', 16, 1);
            RETURN;
        END

		IF NOT EXISTS (SELECT 1 FROM GoodsReceipts WHERE ReceiptID = @ReceiptID)
		BEGIN
			RAISERROR(N'ReceiptID không tồn tại trong bảng GoodsReceipts', 16, 1);
			RETURN;
		END

        IF (@SaleID IS NOT NULL)
        BEGIN
            RAISERROR(N'SaleID phải NULL khi ReturnType = 2', 16, 1);
            RETURN;
        END

        -- Nếu có truyền Phone → lấy SupplierID
        IF (@PartnerPhone IS NOT NULL)
        BEGIN
            SELECT TOP 1
                @SupplierID = SupplierID,
                @PartnerName = SupplierName
            FROM Suppliers
            WHERE Phone = @PartnerPhone;

            IF (@SupplierID IS NULL)
            BEGIN
                RAISERROR(N'Số điện thoại nhà cung cấp không tồn tại', 16, 1);
                RETURN;
            END
        END

        -- 🔥 BẮT BUỘC SupplierID phải có (theo yêu cầu bạn)
        IF (@SupplierID IS NULL)
        BEGIN
            SELECT @SupplierID = SupplierID FROM Returns WHERE ReturnID = @ReturnID;

            IF (@SupplierID IS NULL)
            BEGIN
                RAISERROR(N'SupplierID bắt buộc phải có khi ReturnType = 2', 16, 1);
                RETURN;
            END
        END

        -- Bắt buộc CustomerID NULL
        SET @CustomerID = NULL;
    END

    ELSE
    BEGIN
        RAISERROR(N'ReturnType không hợp lệ', 16, 1);
        RETURN;
    END

    -----------------------------------------
    -- 4. UPDATE DỮ LIỆU
    -----------------------------------------
    UPDATE Returns
    SET
        ReturnType = @ReturnType,

        SaleID = CASE WHEN @ReturnType = 1 THEN @SaleID ELSE NULL END,
        ReceiptID = CASE WHEN @ReturnType = 2 THEN @ReceiptID ELSE NULL END,

        CustomerID = CASE WHEN @ReturnType = 1 THEN @CustomerID ELSE NULL END,
        SupplierID = CASE WHEN @ReturnType = 2 THEN @SupplierID ELSE NULL END,

        PartnerName = ISNULL(@PartnerName, PartnerName),
        PartnerPhone = ISNULL(@PartnerPhone, PartnerPhone),

        ProductID = ISNULL(@ProductID, ProductID),
        ProductName = ISNULL(@ProductName, ProductName),
        Quantity = ISNULL(@Quantity, Quantity),
        UnitPrice = ISNULL(@UnitPrice, UnitPrice),

        ReturnDate = ISNULL(@ReturnDate, ReturnDate),
        Reason = ISNULL(@Reason, Reason)
    WHERE ReturnID = @ReturnID;

    SELECT '';
END;
GO





select * from Payments






CREATE PROCEDURE [dbo].[sp_return_delete]
(
    @ReturnID INT
)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Returns WHERE ReturnID = @ReturnID)
    BEGIN
        RAISERROR(N'ReturnID không tồn tại', 16, 1);
        RETURN;
    END

    DELETE FROM Returns WHERE ReturnID = @ReturnID;

    SELECT 'Xóa thành công' AS Message;
END;
GO




select * from returns


CREATE PROCEDURE [dbo].[sp_return_search]
(
    @page_index  INT, 
    @page_size   INT,

    @ReturnID    NVARCHAR(50) = NULL,
    @ReturnType  NVARCHAR(50) = NULL,
    @SaleID      NVARCHAR(50) = NULL,
    @ReceiptID   NVARCHAR(50) = NULL,
    @CustomerID  NVARCHAR(50) = NULL,
    @SupplierID  NVARCHAR(50) = NULL,    
    @PartnerName NVARCHAR(100) = NULL,
    @PartnerPhone NVARCHAR(20) = NULL,
    @ProductID   NVARCHAR(50) = NULL,

    @FromDate    DATETIME = NULL,
    @ToDate      DATETIME = NULL
)
AS
BEGIN
    DECLARE @RecordCount BIGINT;

    ----------------------------------------------------------------
    -- ✨ CASE 1: CÓ PHÂN TRANG (page_size > 0)
    ----------------------------------------------------------------
    IF (@page_size <> 0)
    BEGIN
        SET NOCOUNT ON;

        SELECT 
            ROW_NUMBER() OVER (ORDER BY r.ReturnID DESC) AS RowNumber,
            r.*
        INTO #Results1
        FROM Returns r
        WHERE 
            (@ReturnID    IS NULL OR CAST(r.ReturnID    AS NVARCHAR(50)) LIKE '%' + @ReturnID + '%')
        AND (@ReturnType  IS NULL OR CAST(r.ReturnType  AS NVARCHAR(50)) LIKE '%' + @ReturnType + '%')
        AND (@SaleID      IS NULL OR CAST(r.SaleID      AS NVARCHAR(50)) LIKE '%' + @SaleID + '%')
        AND (@ReceiptID   IS NULL OR CAST(r.ReceiptID   AS NVARCHAR(50)) LIKE '%' + @ReceiptID + '%')
        AND (@CustomerID  IS NULL OR CAST(r.CustomerID  AS NVARCHAR(50)) LIKE '%' + @CustomerID + '%')
        AND (@SupplierID  IS NULL OR CAST(r.SupplierID  AS NVARCHAR(50)) LIKE '%' + @SupplierID + '%')
        AND (@PartnerName IS NULL OR r.PartnerName LIKE '%' + @PartnerName + '%')
        AND (@PartnerPhone IS NULL OR r.PartnerPhone LIKE '%' + @PartnerPhone + '%')
        AND (@ProductID   IS NULL OR CAST(r.ProductID   AS NVARCHAR(50)) LIKE '%' + @ProductID + '%')
        AND (@FromDate IS NULL OR r.ReturnDate >= @FromDate)
        AND (@ToDate   IS NULL OR r.ReturnDate <= @ToDate);


        SELECT @RecordCount = COUNT(*) FROM #Results1;

        SELECT *, @RecordCount AS RecordCount
        FROM #Results1
        WHERE RowNumber BETWEEN (@page_index - 1) * @page_size + 1
                            AND (@page_index * @page_size);

        DROP TABLE #Results1;
    END
    ----------------------------------------------------------------
    -- ✨ CASE 2: KHÔNG PHÂN TRANG (page_size = 0)
    ----------------------------------------------------------------
    ELSE
    BEGIN
        SET NOCOUNT ON;

        SELECT 
            ROW_NUMBER() OVER (ORDER BY r.ReturnID DESC) AS RowNumber,
            r.*
        INTO #Results2
        FROM Returns r
        WHERE 
            (@ReturnID    IS NULL OR CAST(r.ReturnID    AS NVARCHAR(50)) LIKE '%' + @ReturnID + '%')
        AND (@ReturnType  IS NULL OR CAST(r.ReturnType  AS NVARCHAR(50)) LIKE '%' + @ReturnType + '%')
        AND (@SaleID      IS NULL OR CAST(r.SaleID      AS NVARCHAR(50)) LIKE '%' + @SaleID + '%')
        AND (@ReceiptID   IS NULL OR CAST(r.ReceiptID   AS NVARCHAR(50)) LIKE '%' + @ReceiptID + '%')
        AND (@CustomerID  IS NULL OR CAST(r.CustomerID  AS NVARCHAR(50)) LIKE '%' + @CustomerID + '%')
        AND (@SupplierID  IS NULL OR CAST(r.SupplierID  AS NVARCHAR(50)) LIKE '%' + @SupplierID + '%')
        AND (@PartnerName IS NULL OR r.PartnerName LIKE '%' + @PartnerName + '%')
        AND (@PartnerPhone IS NULL OR r.PartnerPhone LIKE '%' + @PartnerPhone + '%')
        AND (@ProductID   IS NULL OR CAST(r.ProductID   AS NVARCHAR(50)) LIKE '%' + @ProductID + '%')
        AND (@FromDate IS NULL OR r.ReturnDate >= @FromDate)
        AND (@ToDate   IS NULL OR r.ReturnDate <= @ToDate);

        SELECT @RecordCount = COUNT(*) FROM #Results2;

        SELECT *, @RecordCount AS RecordCount
        FROM #Results2
        ORDER BY ReturnID DESC;

        DROP TABLE #Results2;
    END
END
GO









INSERT INTO Returns 
(ReturnType, SaleID, CustomerID, PartnerName, PartnerPhone,
 ReturnDate, Reason, ProductID, ProductName, Quantity, UnitPrice)
VALUES

(1, 2, 2,  N'Khách Hàng 2',  '0923000002', '2025-03-10', N'Không vừa size',       2,  N'Sản phẩm 2',  1, 495000),
(1, 3, 3,  N'Khách Hàng 3',  '0923000003', '2025-03-11', N'Màu không giống hình', 3,  N'Sản phẩm 3',  1, 560000),
(1, 4, 4,  N'Khách Hàng 4',  '0923000004', '2025-03-11', N'Lỗi đường chỉ',        4,  N'Sản phẩm 4',  1, 540000),
(1, 5, 5,  N'Khách Hàng 5',  '0923000005', '2025-03-12', N'Bị trầy xước',          5,  N'Sản phẩm 5',  1, 560000),
(1, 6, 6,  N'Khách Hàng 6',  '0923000006', '2025-03-12', N'Không đúng mẫu đặt',    6,  N'Sản phẩm 6',  1, 450000),
(1, 7, 7,  N'Khách Hàng 7',  '0923000007', '2025-03-13', N'Trầy đế giày',          7,  N'Sản phẩm 7',  1, 460000),
(1, 8, 8,  N'Khách Hàng 8',  '0923000008', '2025-03-13', N'Không hợp phong cách',  8,  N'Sản phẩm 8',  1, 700000),
(1, 9, 9,  N'Khách Hàng 9',  '0923000009', '2025-03-14', N'Lỗi form',              9,  N'Sản phẩm 9',  1, 1050000),
(1, 10, 10, N'Khách Hàng 10','0923000010', '2025-03-14', N'Nhăn da',              10, N'Sản phẩm 10', 1, 630000),
(1, 11, 11, N'Khách Hàng 11','0923000011', '2025-03-15', N'Sai size khi giao',    11, N'Sản phẩm 11', 1, 520000),
(1, 12, 12, N'Khách Hàng 12','0923000012', '2025-03-15', N'Lỗi dáng giày',        12, N'Sản phẩm 12', 1, 920000),
(1, 13, 13, N'Khách Hàng 13','0923000013', '2025-03-16', N'Không ưng màu',        13, N'Sản phẩm 13', 1, 150000),
(1, 14, 14, N'Khách Hàng 14','0923000014', '2025-03-16', N'Không thoải mái',      14, N'Sản phẩm 14', 1, 250000),
(1, 15, 15, N'Khách Hàng 15','0923000015', '2025-03-17', N'Gót giày cứng',        15, N'Sản phẩm 15', 1, 580000);




select * from Returns


INSERT INTO Returns 
(ReturnType, ReceiptID, SupplierID, PartnerName, PartnerPhone,
 ReturnDate, Reason, ProductID, ProductName, Quantity, UnitPrice)
VALUES
(2, 1, 1,   N'Nhà Cung Cấp A', '0912000001', '2025-03-10', N'Hàng lỗi khi nhập',           1,  N'Sản phẩm 1',  2, 450000),
(2, 2, 2,   N'Nhà Cung Cấp B', '0912000002', '2025-03-18', N'Không đúng số lượng',         2,  N'Sản phẩm 2',  3, 470000),
(2, 3, 3,   N'Nhà Cung Cấp C', '0912000003', '2025-03-19', N'Hỏng đế giày',                3,  N'Sản phẩm 3',  1, 520000),
(2, 4, 4,   N'Nhà Cung Cấp D', '0912000004', '2025-03-19', N'Lỗi da bề mặt',              4,  N'Sản phẩm 4',  2, 500000),
(2, 5, 5,   N'Nhà Cung Cấp E', '0912000005', '2025-03-20', N'Móp mũi giày',               5,  N'Sản phẩm 5',  1, 530000),
(2, 6, 6,   N'Nhà Cung Cấp F', '0912000006', '2025-03-14', N'Sai model',                   6,  N'Sản phẩm 6',  4, 410000),
(2, 7, 7,   N'Nhà Cung Cấp G', '0912000007', '2025-06-03', N'Kém chất lượng',              7,  N'Sản phẩm 7',  3, 420000),
(2, 8, 8,   N'Nhà Cung Cấp H', '0912000008', '2025-06-12', N'Lỗi phần đế',                8,  N'Sản phẩm 8',  2, 650000),
(2, 9, 9,   N'Nhà Cung Cấp I', '0912000009', '2025-06-22', N'Giày thấm nước',             9,  N'Sản phẩm 9',  1, 980000),
(2, 10, 10, N'Nhà Cung Cấp J', '0912000010', '2025-09-22', N'Lỗi màu sắc',               10, N'Sản phẩm 10', 3, 590000),
(2, 11, 11, N'Nhà Cung Cấp K', '0912000011', '2025-09-28', N'Lỗi keo dán',               11, N'Sản phẩm 11', 2, 480000),
(2, 12, 12, N'Nhà Cung Cấp L', '0912000012', '2025-09-16', N'Suốt chỉ',                  12, N'Sản phẩm 12', 1, 880000),
(2, 13, 13, N'Nhà Cung Cấp M', '0912000013', '2025-09-24', N'Lỗi form giày',             13, N'Sản phẩm 13', 5, 120000),
(2, 14, 14, N'Nhà Cung Cấp N', '0912000014', '2025-10-02', N'Giày nứt đế',               14, N'Sản phẩm 14', 4, 220000),
(2, 15, 15, N'Nhà Cung Cấp O', '0912000015', '2025-10-16', N'Lỗi cao su đế',             15, N'Sản phẩm 15', 2, 540000);
