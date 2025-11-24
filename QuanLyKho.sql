create database QLBanLeKho
use QLBanLeKho

create database QLBanLeKho
delete Products
drop database QLBanLeKho


----------------------------------------------------
-- 1. XÓA BẢNG CHI TIẾT TRƯỚC (TRÁNH LỖI FK)
----------------------------------------------------
DELETE FROM SalesItems;
DBCC CHECKIDENT ('SalesItems', RESEED, 0);

DELETE FROM GoodsIssueDetails;
DBCC CHECKIDENT ('GoodsIssueDetails', RESEED, 0);

DELETE FROM GoodsReceiptDetails;
DBCC CHECKIDENT ('GoodsReceiptDetails', RESEED, 0);

DELETE FROM PurchaseOrderDetails;
DBCC CHECKIDENT ('PurchaseOrderDetails', RESEED, 0);

DELETE FROM Returns;
DBCC CHECKIDENT ('Returns', RESEED, 0);

DELETE FROM Payments;
DBCC CHECKIDENT ('Payments', RESEED, 0);

DELETE FROM StockCards;
DBCC CHECKIDENT ('StockCards', RESEED, 0);

DELETE FROM Promotions;
DBCC CHECKIDENT ('Promotions', RESEED, 0);

----------------------------------------------------
-- 2. XÓA BẢNG MASTER TRUNG GIAN
----------------------------------------------------
DELETE FROM Sales;
DBCC CHECKIDENT ('Sales', RESEED, 0);

DELETE FROM GoodsIssues;
DBCC CHECKIDENT ('GoodsIssues', RESEED, 0);

DELETE FROM GoodsReceipts;
DBCC CHECKIDENT ('GoodsReceipts', RESEED, 0);

DELETE FROM PurchaseOrders;
DBCC CHECKIDENT ('PurchaseOrders', RESEED, 0);

DELETE FROM Invoices;
DBCC CHECKIDENT ('Invoices', RESEED, 0);



----------------------------------------------------
-- 3. XÓA BẢNG CHÍNH
----------------------------------------------------
DELETE FROM Products;
DBCC CHECKIDENT ('Products', RESEED, 0);

DELETE FROM Categories;
DBCC CHECKIDENT ('Categories', RESEED, 0);

DELETE FROM Suppliers;
DBCC CHECKIDENT ('Suppliers', RESEED, 0);

DELETE FROM Customers;
DBCC CHECKIDENT ('Customers', RESEED, 0);

DELETE FROM Users;
DBCC CHECKIDENT ('Users', RESEED, 0);




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
	VATRate DECIMAL(5,2)NULL 
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
    Image NVARCHAR(255) NULL,                  -- Hình ảnh
    VATRate DECIMAL(5,2) NULL,                             -- Thuế VAT
    Quantity INT DEFAULT 0,                           -- Số lượng tồn
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

drop table Products
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
	 Status VARCHAR(20) DEFAULT 'pending',
    FOREIGN KEY (POID) REFERENCES PurchaseOrders(POID) ON DELETE CASCADE,
	FOREIGN KEY (UserID) REFERENCES Users(UserID) -- Thiết lập khóa ngoại
);
ALTER TABLE GoodsReceipts
ADD Status VARCHAR(20) DEFAULT 'pending'

select * from GoodsReceipts


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

select * from GoodsReceiptDetails


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


select * from Users



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








INSERT INTO Products 
(SKU, Barcode, ProductName, CategoryID, UnitPrice, Unit, MinStock, Status, Image, VATRate, Quantity) 
VALUES
('SKU001', 'BC001', N'Giày Sneaker Trắng',            1, 850000, N'Đôi', 10, 'Active', N'Products\Giày Sneaker Trắng.jpg',      15.00, 0),
('SKU002', 'BC002', N'Giày Sneaker Đen',              1, 850000, N'Đôi', 10, 'Active', N'Products\Giày Sneaker Đen.jpg',        10.00, 0),
('SKU003', 'BC003', N'Giày Chạy Bộ Nam',              8, 950000, N'Đôi', 5,  'Active', N'Products\Giày Chạy Bộ Nam.jpg',        20.00, 0),
('SKU004', 'BC004', N'Giày Chạy Bộ Nữ',               8, 920000, N'Đôi', 5,  'Active', N'Products\Giày Chạy Bộ Nữ.jpg',         10.00, 0),
('SKU005', 'BC005', N'Giày Tennis Trắng',             11,1100000, N'Đôi', 3,  'Active', N'Products\Giày Tennis Trắng.jpg',       10.00, 0),
('SKU006', 'BC006', N'Giày Bóng Đá Cỏ Tự Nhiên',      13,1200000, N'Đôi', 7,  'Active', N'Products\Giày Bóng Đá Cỏ Tự Nhiên.jpg',10.00, 0),
('SKU007', 'BC007', N'Giày Bóng Đá Cỏ Nhân Tạo',      13,1100000, N'Đôi', 7,  'Active', N'Products\Giày Bóng Đá Cỏ Nhân Tạo.jpg',20.00, 0),
('SKU008', 'BC008', N'Giày Bóng Rổ Cao Cổ',           14,1300000, N'Đôi', 6,  'Active', N'Products\Giày Bóng Rổ Cao Cổ.jpg',    0.00,  0),
('SKU009', 'BC009', N'Giày Golf Chống Thấm',          12,1500000, N'Đôi', 2,  'Active', N'Products\Giày Golf Chống Thấm.jpg',   10.00, 0),
('SKU010', 'BC010', N'Giày Tây Nam',                  4, 650000, N'Đôi', 4,  'Active', N'Products\Giày Tây Nam.jpg',             10.00, 0),
('SKU011', 'BC011', N'Giày Cao Gót Đen',              5, 700000, N'Đôi', 3,  'Active', N'Products\Giày Cao Gót Đen.jpg',         0.00,  0),
('SKU012', 'BC012', N'Giày Boot Da',                  6, 1400000, N'Đôi', 2, 'Active', N'Products\Giày Boot Da.jpg',             20.00, 0),
('SKU013', 'BC013', N'Dép Lê Nam',                    3, 150000, N'Đôi', 20, 'Active', N'Products\Dép Lê Nam.jpg',               15.00, 0),
('SKU014', 'BC014', N'Sandal Nữ Thời Trang',          2, 300000, N'Đôi', 15, 'Active', N'Products\Sandal Nữ Thời Trang.jpg',     15.00, 0),
('SKU015', 'BC015', N'Giày Lười Nam',                 10,550000, N'Đôi', 8,  'Active', N'Products\Giày Lười Nam.jpg',            0.00,  0);








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







DELETE FROM GoodsReceipts;
DBCC CHECKIDENT ('GoodsReceipts', RESEED, 0);



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


select *from GoodsReceipts



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


UPDATE GoodsReceiptDetails SET ExpiryDate = '2025-11-30' WHERE ProductID = 1;
UPDATE GoodsReceiptDetails SET ExpiryDate = '2026-2-25' WHERE ProductID = 2;
UPDATE GoodsReceiptDetails SET ExpiryDate = '2025-11-26' WHERE ProductID = 3;
UPDATE GoodsReceiptDetails SET ExpiryDate = '2026-03-22' WHERE ProductID = 4;
UPDATE GoodsReceiptDetails SET ExpiryDate = '2026-01-05' WHERE ProductID = 5;
UPDATE GoodsReceiptDetails SET ExpiryDate = '2025-12-31' WHERE ProductID = 6;
UPDATE GoodsReceiptDetails SET ExpiryDate = '2025-12-31' WHERE ProductID = 7;
UPDATE GoodsReceiptDetails SET ExpiryDate = '2025-12-15' WHERE ProductID = 8;
UPDATE GoodsReceiptDetails SET ExpiryDate = '2025-12-23' WHERE ProductID = 9;
UPDATE GoodsReceiptDetails SET ExpiryDate = '2026-02-01' WHERE ProductID = 10;
UPDATE GoodsReceiptDetails SET ExpiryDate = '2025-11-30' WHERE ProductID = 11;
UPDATE GoodsReceiptDetails SET ExpiryDate = '2025-12-22' WHERE ProductID = 12;
UPDATE GoodsReceiptDetails SET ExpiryDate = '2026-09-12' WHERE ProductID = 13;
UPDATE GoodsReceiptDetails SET ExpiryDate = '2026-12-31' WHERE ProductID = 14;
UPDATE GoodsReceiptDetails SET ExpiryDate = '2026-07-30' WHERE ProductID = 15;





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



select * from  SalesItems













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
SELECT * FROM GoodsReceiptDetails;
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

DELETE FROM Payments;

SELECT TOP 10 ProductID, UnitPrice 
FROM GoodsReceiptDetails
ORDER BY ReceiptID DESC


SELECT * FROM Categories;
SELECT * FROM Suppliers;
SELECT * FROM Products;
SELECT * FROM Sales;
SELECT * FROM SalesItems;



DELETE GoodsIssues;
DELETE GoodsIssueDetails
DELETE StockCards;
DELETE Returns;
DELETE Payments;
DELETE Invoices;
DELETE GoodsReceipts;
DELETE GoodsReceiptDetails;
DELETE Sales;
DELETE SalesItems;


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
        CAST(GETDATE() AS DATE), -- tự động lấy ngày hiện tại
        @Method,
        @Description
    );

    SELECT SCOPE_IDENTITY() AS NewPaymentID;
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










--trigger tự động nhập supplierID qua receiptID
CREATE TRIGGER trg_AfterInsert_Payments
ON Payments
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Cập nhật SupplierID trong Payments dựa vào ReceiptID -> GoodsReceipts -> PurchaseOrders
    UPDATE p
    SET p.SupplierID = po.SupplierID
    FROM Payments p
    INNER JOIN inserted i ON p.PaymentID = i.PaymentID
    INNER JOIN GoodsReceipts gr ON i.ReceiptID = gr.ReceiptID
    INNER JOIN PurchaseOrders po ON gr.POID = po.POID
    WHERE i.ReceiptID IS NOT NULL;
END;
GO


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

ư

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
    @Description  NVARCHAR(255),
    @VATRate DECIMAL(5,2) = NULL  -- cho phép null
)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Categories (CategoryName, [Description], VATRate)
    VALUES (@CategoryName, @Description, @VATRate);

    -- Tr? v? chu?i r?ng thay vì ID m?i
    SELECT '';
END
GO



select * from Settings


EXEC sp_category_create
  @CategoryName='gggg', 
  @Description='gggg', 
  @VATRate=NULL



EXEC dbo.sp_category_create 
    @CategoryName = N'Th?c ph?m',
    @Description  = N'Hàng th?c ph?m',
    @VATRate = NULL;






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


















CREATE OR ALTER PROCEDURE [dbo].[sp_product_search]
(
    @page_index  INT = 1, 
    @page_size   INT = 20,
    @ProductID   INT = NULL,
    @SKU         VARCHAR(50) = '',
    @Barcode     VARCHAR(50) = '',
    @ProductName NVARCHAR(100) = '',
    @CategoryID  INT = NULL,
    @Status      NVARCHAR(20) = '',
    @MinPrice    DECIMAL(18,2) = NULL,
    @MaxPrice    DECIMAL(18,2) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH Filtered AS 
    (
        SELECT 
            p.ProductID,
            p.SKU,
            p.Barcode,
            p.ProductName,
            p.CategoryID,
            p.UnitPrice,
            p.Unit,
            p.MinStock,
            p.Status,
            p.Image,
            p.VATRate,
            p.Quantity,

            ROW_NUMBER() OVER (ORDER BY p.ProductID DESC) AS RowNum,
            COUNT(*) OVER() AS TotalCount
        FROM Products p WITH (NOLOCK)

        WHERE 
            (@ProductID IS NULL OR p.ProductID = @ProductID)
            AND (@SKU = '' OR p.SKU LIKE @SKU + '%')       -- Tối ưu LIKE
            AND (@Barcode = '' OR p.Barcode LIKE @Barcode + '%')
            AND (@ProductName = '' 
                 OR p.ProductName LIKE N'%' + @ProductName + '%')
            AND (@CategoryID IS NULL OR p.CategoryID = @CategoryID)
            AND (@Status = '' OR p.Status = @Status)
            AND (@MinPrice IS NULL OR p.UnitPrice >= @MinPrice)
            AND (@MaxPrice IS NULL OR p.UnitPrice <= @MaxPrice)
    )

    SELECT *
    FROM Filtered
    WHERE 
        @page_size = 0
        OR (RowNum BETWEEN (@page_index - 1) * @page_size + 1
                        AND  @page_index * @page_size)
    ORDER BY RowNum;
END;
GO
CREATE INDEX IX_Products_SKU ON Products(SKU);
CREATE INDEX IX_Products_Barcode ON Products(Barcode);
CREATE INDEX IX_Products_ProductName ON Products(ProductName);
CREATE INDEX IX_Products_CategoryID ON Products(CategoryID);
CREATE INDEX IX_Products_Status ON Products(Status);
CREATE INDEX IX_Products_UnitPrice ON Products(UnitPrice);








DELETE FROM Products;
DBCC CHECKIDENT ('Products', RESEED, 0);

DECLARE @i INT = 1;

-----------------------------------------------------
-- BẢNG SẢN PHẨM GỐC (NAME + CATEGORY)
-----------------------------------------------------
DECLARE @Products TABLE (Name NVARCHAR(200), Cat INT);
INSERT INTO @Products VALUES
(N'Balo Laptop chống sốc 15.6 inch', 8),
(N'Túi chống sốc Macbook Air/Pro', 8),
(N'Bàn phím cơ LED RGB', 2),
(N'Bàn phím văn phòng chống nước', 2),
(N'Cáp sạc nhanh Type-C 3A', 3),
(N'Củ sạc nhanh PD 20W', 3),
(N'Chuột không dây Logitech', 4),
(N'Chuột gaming DPI cao', 4),
(N'Loa Bluetooth mini', 5),
(N'Loa Bluetooth chống nước', 5),
(N'USB 32GB 3.0', 6),
(N'SSD 240GB SATA III', 6),
(N'HDD 1TB 3.5 inch', 6),
(N'Ốp lưng iPhone chống sốc', 7),
(N'Ốp lưng Samsung TPU', 7),
(N'Kính cường lực iPhone', 7),
(N'Pin dự phòng 10000mAh', 10),
(N'Pin dự phòng 20000mAh', 10),
(N'Giá đỡ laptop chống trượt', 9),
(N'Bộ vệ sinh laptop', 9),
(N'Giá đỡ điện thoại để bàn', 9),
(N'Hub USB Type-C 5-in-1', 9),
(N'Tai nghe chụp tai Bluetooth', 3),
(N'Tai nghe in-ear chống ồn', 3),
(N'Tai nghe chụp gaming RGB', 3),
(N'Webcam Full HD 1080p', 9),
(N'Micro thu âm livestream', 9),
(N'Bàn di chuột lớn', 4),
(N'Đế tản nhiệt laptop 2 quạt', 9),
(N'Cáp HDMI 1.5m', 3),
(N'Cáp DisplayPort 1.4', 3);

-----------------------------------------------------
-- BẢNG ÁNH XẠ TÊN → ẢNH
-----------------------------------------------------
DECLARE @ImageMap TABLE (Name NVARCHAR(200), Image NVARCHAR(255));
INSERT INTO @ImageMap VALUES
(N'Balo Laptop chống sốc 15.6 inch', N'Products\Balo Laptop chống sốc 15.6 inch.png'),
(N'Túi chống sốc Macbook Air/Pro', N'Products\Túi chống sốc Macbook AirPro.png'),
(N'Bàn phím cơ LED RGB', N'Products\Bàn phím cơ LED RGB.png'),
(N'Bàn phím văn phòng chống nước', N'Products\Bàn phím văn phòng chống nước.png'),
(N'Cáp sạc nhanh Type-C 3A', N'Products\Cáp sạc nhanh Type-C 3A.png'),
(N'Củ sạc nhanh PD 20W', N'Products\Củ sạc nhanh PD 20W.png'),
(N'Chuột không dây Logitech', N'Products\Chuột không dây Logitech.png'),
(N'Chuột gaming DPI cao', N'Products\Chuột gaming DPI cao.png'),
(N'Loa Bluetooth mini', N'Products\Loa Bluetooth mini.png'),
(N'Loa Bluetooth chống nước', N'Products\Loa Bluetooth chống nước.png'),
(N'USB 32GB 3.0', N'Products\USB 32GB 3.0.png'),
(N'SSD 240GB SATA III', N'Products\SSD 240GB SATA III.png'),
(N'HDD 1TB 3.5 inch', N'Products\HDD 1TB 3.5 inch.png'),
(N'Ốp lưng iPhone chống sốc', N'Products\Ốp lưng iPhone chống sốc.png'),
(N'Ốp lưng Samsung TPU', N'Products\Ốp lưng Samsung TPU.png'),
(N'Kính cường lực iPhone', N'Products\Kính cường lực iPhone.png'),
(N'Pin dự phòng 10000mAh', N'Products\Pin dự phòng 10000mAh.png'),
(N'Pin dự phòng 20000mAh', N'Products\Pin dự phòng 20000mAh.png'),
(N'Giá đỡ laptop chống trượt', N'Products\Giá đỡ laptop chống trượt.png'),
(N'Bộ vệ sinh laptop', N'Products\Bộ vệ sinh laptop.png'),
(N'Giá đỡ điện thoại để bàn', N'Products\Giá đỡ điện thoại để bàn.png'),
(N'Hub USB Type-C 5-in-1', N'Products\Hub USB Type-C 5-in-1.png'),
(N'Tai nghe chụp tai Bluetooth', N'Products\Tai nghe chụp tai Bluetooth.png'),
(N'Tai nghe in-ear chống ồn', N'Products\Tai nghe in-ear chống ồn.png'),
(N'Tai nghe chụp gaming RGB', N'Products\Tai nghe chụp gaming RGB.png'),
(N'Webcam Full HD 1080p', N'Products\Webcam Full HD 1080p.png'),
(N'Micro thu âm livestream', N'Products\Micro thu âm livestream.png'),
(N'Bàn di chuột lớn', N'Products\Bàn di chuột lớn.png'),
(N'Đế tản nhiệt laptop 2 quạt', N'Products\Đế tản nhiệt laptop 2 quạt.png'),
(N'Cáp HDMI 1.5m', N'Products\Cáp HDMI 1.5m.png'),
(N'Cáp DisplayPort 1.4', N'Products\Cáp DisplayPort 1.4.png');

-----------------------------------------------------
-- BẢNG GIÁ
-----------------------------------------------------
DECLARE @PriceList TABLE (Price INT);
INSERT INTO @PriceList VALUES
(50000), (69000), (89000), (99000),
(120000), (150000), (199000), (249000), (299000), (350000),
(399000), (450000), (499000), (550000), (590000),
(650000), (690000), (750000),
(890000), (990000), (1290000), (1490000), (1590000),
(1790000), (1990000), (2290000), (2490000),
(2690000), (2990000);

-----------------------------------------------------
-- INSERT 500 SẢN PHẨM
-----------------------------------------------------
WHILE (@i <= 500)
BEGIN
    DECLARE @Name NVARCHAR(200),
            @Cat INT,
            @Img NVARCHAR(255);

    SELECT TOP 1
        @Name = Name,
        @Cat = Cat
    FROM @Products
    ORDER BY NEWID();

    SELECT @Img = Image FROM @ImageMap WHERE Name = @Name;

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
        Image,
        VATRate,
        Quantity
    )
    VALUES
    (
        'SKU' + RIGHT('0' + CAST(@i AS VARCHAR(6)), 6),
        CAST(10000 + @i AS VARCHAR(20)),
        @Name,
        @Cat,
        (SELECT TOP 1 Price FROM @PriceList ORDER BY NEWID()),
        N'Cái',
        (SELECT TOP 1 (2 + ABS(CHECKSUM(NEWID())) % 8)),
        N'Active',
        @Img,
        8.00,
        (SELECT TOP 1 (5 + ABS(CHECKSUM(NEWID())) % 96))
    );

    SET @i += 1;
END;











CREATE OR ALTER PROCEDURE [dbo].[sp_product_get_by_id]
    @ProductID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM Products WITH (NOLOCK)
    WHERE ProductID = @ProductID;
END;
GO




CREATE OR ALTER PROCEDURE [dbo].[sp_product_delete]
    @ProductID INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM SalesItems WHERE ProductID = @ProductID;
    DELETE FROM StockCards WHERE ProductID = @ProductID;
    DELETE FROM GoodsReceiptDetails WHERE ProductID = @ProductID;
    DELETE FROM PurchaseOrderDetails WHERE ProductID = @ProductID;
    DELETE FROM GoodsIssueDetails WHERE ProductID = @ProductID;

    DELETE FROM Products WHERE ProductID = @ProductID;

    SELECT 'Xóa sản phẩm thành công' AS Message;
END;
GO




CREATE OR ALTER PROCEDURE [dbo].[sp_product_create]
(
    @SKU         VARCHAR(50),
    @Barcode     VARCHAR(50),
    @ProductName NVARCHAR(100),
    @CategoryID  INT,
    @UnitPrice   DECIMAL(18,2) = 0,
    @Unit        NVARCHAR(20) = NULL,
    @MinStock    INT = 0,
    @Status      NVARCHAR(20) = 'Active',
    @Image       NVARCHAR(255) = NULL,
    @VATRate     DECIMAL(5,2) = NULL,  
    @Quantity    INT = 0
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- 🔍 Validate bắt buộc
        IF (LTRIM(RTRIM(@SKU)) = '')
            RAISERROR(N'SKU không được để trống.',16,1);

        IF (LTRIM(RTRIM(@Barcode)) = '')
            RAISERROR(N'Barcode không được để trống.',16,1);

        IF (LTRIM(RTRIM(@ProductName)) = '')
            RAISERROR(N'Tên sản phẩm không được để trống.',16,1);

        IF (@CategoryID IS NULL)
            RAISERROR(N'CategoryID không được để trống.',16,1);

        -- 🔍 Check CategoryID tồn tại
        IF NOT EXISTS (SELECT 1 FROM Categories WHERE CategoryID = @CategoryID)
            RAISERROR(N'CategoryID không tồn tại.',16,1);

        -- 🔍 SKU trùng
        IF EXISTS (SELECT 1 FROM Products WHERE SKU = @SKU)
            RAISERROR(N'SKU "%s" đã tồn tại.',16,1, @SKU);

        -- 🔍 Barcode trùng
        IF EXISTS (SELECT 1 FROM Products WHERE Barcode = @Barcode)
            RAISERROR(N'Barcode "%s" đã tồn tại.',16,1, @Barcode);

        -- 🔍 Lấy VATRate từ Category nếu không truyền
        IF (@VATRate IS NULL)
        BEGIN
            SELECT @VATRate = VATRate 
            FROM Categories 
            WHERE CategoryID = @CategoryID;
        END

        -- ➕ INSERT
        INSERT INTO Products
        (
            SKU, Barcode, ProductName, CategoryID,
            UnitPrice, Unit, MinStock, Status,
            Image, VATRate, Quantity
        )
        VALUES
        (
            @SKU, @Barcode, @ProductName, @CategoryID,
            @UnitPrice, @Unit, @MinStock, @Status,
            @Image, @VATRate, @Quantity
        );

        SELECT SCOPE_IDENTITY() AS NewProductID;
    END TRY

    BEGIN CATCH
        DECLARE @Err NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@Err, 16, 1);
    END CATCH
END;
GO




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
    @Image       NVARCHAR(255) = NULL,
    @VATRate     DECIMAL(5,2) = NULL,
    @Quantity    INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Kiểm tra ProductID hợp lệ
        IF NOT EXISTS (SELECT 1 FROM Products WHERE ProductID = @ProductID)
            RAISERROR(N'ProductID không tồn tại.', 16, 1);

        DECLARE @FinalCategoryID INT;

        -- Lấy CategoryID nếu không truyền vào
        SELECT @FinalCategoryID =
            CASE WHEN @CategoryID IS NULL THEN CategoryID ELSE @CategoryID END
        FROM Products 
        WHERE ProductID = @ProductID;

        -- Kiểm tra CategoryID hợp lệ
        IF NOT EXISTS (SELECT 1 FROM Categories WHERE CategoryID = @FinalCategoryID)
            RAISERROR(N'CategoryID không hợp lệ.',16,1);

        -- Lấy VAT từ Category nếu không truyền
        IF (@VATRate IS NULL)
        BEGIN
            SELECT @VATRate = VATRate 
            FROM Categories 
            WHERE CategoryID = @FinalCategoryID;
        END

        -- Kiểm tra SKU trùng
        IF (@SKU IS NOT NULL AND EXISTS (
            SELECT 1 FROM Products WHERE SKU = @SKU AND ProductID <> @ProductID))
            RAISERROR(N'SKU "%s" đã tồn tại.', 16, 1, @SKU);

        -- Kiểm tra Barcode trùng
        IF (@Barcode IS NOT NULL AND EXISTS (
            SELECT 1 FROM Products WHERE Barcode = @Barcode AND ProductID <> @ProductID))
            RAISERROR(N'Barcode "%s" đã tồn tại.', 16, 1, @Barcode);

        -- UPDATE
        UPDATE Products
        SET
            SKU         = COALESCE(@SKU, SKU),
            Barcode     = COALESCE(@Barcode, Barcode),
            ProductName = COALESCE(@ProductName, ProductName),
            CategoryID  = COALESCE(@CategoryID, CategoryID),
            UnitPrice   = COALESCE(@UnitPrice, UnitPrice),
            Unit        = COALESCE(@Unit, Unit),
            MinStock    = COALESCE(@MinStock, MinStock),
            Status      = COALESCE(@Status, Status),
            Image       = COALESCE(@Image, Image),
            VATRate     = COALESCE(@VATRate, VATRate),
            Quantity    = COALESCE(@Quantity, Quantity)
        WHERE ProductID = @ProductID;

        SELECT 'Update thành công' AS Message;
    END TRY

    BEGIN CATCH
        DECLARE @ErrMsg NVARCHAR(4000), @ErrSeverity INT;

        SELECT 
            @ErrMsg = ERROR_MESSAGE(),
            @ErrSeverity = ERROR_SEVERITY();

        RAISERROR(@ErrMsg, @ErrSeverity, 1);
    END CATCH
END;
GO





CREATE OR ALTER PROCEDURE [dbo].[sp_product_search]
(
    @page_index  INT = 1, 
    @page_size   INT = 20,
    @ProductID   INT = NULL,
    @SKU         VARCHAR(50) = '',
    @Barcode     VARCHAR(50) = '',
    @ProductName NVARCHAR(100) = '',
    @CategoryID  INT = NULL,
    @Status      NVARCHAR(20) = '',
    @MinPrice    DECIMAL(18,2) = NULL,
    @MaxPrice    DECIMAL(18,2) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH Filtered AS 
    (
        SELECT 
            p.ProductID,
            p.SKU,
            p.Barcode,
            p.ProductName,
            p.CategoryID,
            p.UnitPrice,
            p.Unit,
            p.MinStock,
            p.Status,
            p.Image,
            p.VATRate,
            p.Quantity,

            ROW_NUMBER() OVER (ORDER BY p.ProductID DESC) AS RowNum,
            COUNT(*) OVER() AS TotalCount
        FROM Products p WITH (NOLOCK)

        WHERE 
            (@ProductID IS NULL OR p.ProductID = @ProductID)
            AND (@SKU = '' OR p.SKU LIKE N'%' + @SKU + '%')       -- Tối ưu LIKE
            AND (@Barcode = '' OR p.Barcode LIKE N'%' + @Barcode + '%')
            AND (@ProductName = '' 
                 OR p.ProductName LIKE N'%' + @ProductName + '%')
            AND (@CategoryID IS NULL OR p.CategoryID = @CategoryID)
            AND (@Status = '' OR p.Status = @Status)
            AND (@MinPrice IS NULL OR p.UnitPrice >= @MinPrice)
            AND (@MaxPrice IS NULL OR p.UnitPrice <= @MaxPrice)
    )

    SELECT *
    FROM Filtered
    WHERE 
        @page_size = 0
        OR (RowNum BETWEEN (@page_index - 1) * @page_size + 1
                        AND  @page_index * @page_size)
    ORDER BY RowNum;
END;
GO



select * from Products







-----------------------------------------------------
-- phần sét tinh
-----------------------------------------------------
CREATE TABLE Settings (
    SettingID INT IDENTITY(1,1) PRIMARY KEY,
    VATRate DECIMAL(5,2) NOT NULL,              -- Thu? m?c d?nh, luôn có giá tr?
    DefaultLanguage VARCHAR(5) NOT NULL,        -- EN ho?c VI
    LastUpdated DATETIME DEFAULT GETDATE()
);
INSERT INTO Settings (VATRate, DefaultLanguage) 
VALUES (10.00, 'EN');


ALTER TABLE Categories 
ALTER COLUMN VATRate DECIMAL(5,2) NULL;


SELECT 
    c.CategoryName,
    ISNULL(c.VATRate, s.VATRate) AS AppliedVAT
FROM Categories c
CROSS JOIN Settings s;



CREATE VIEW vw_CategoriesWithVAT AS
SELECT 
    c.CategoryID,
    c.CategoryName,
    c.Description,
    ISNULL(c.VATRate, s.VATRate) AS VATRate
FROM Categories c
CROSS JOIN Settings s;


SELECT DefaultLanguage FROM Settings;



CREATE TRIGGER trg_Categories_DefaultVAT
ON Categories
FOR INSERT
AS
BEGIN
    UPDATE c
    SET VATRate = s.VATRate
    FROM Categories c
    JOIN inserted i ON c.CategoryID = i.CategoryID
    CROSS JOIN Settings s
    WHERE i.VATRate IS NULL;
END


CREATE TABLE Languages (
    LangCode VARCHAR(5) PRIMARY KEY,   -- EN, VI
    LangName NVARCHAR(50) NOT NULL     -- English, Ti?ng Vi?t
);


INSERT INTO Languages (LangCode, LangName)
VALUES ('EN', 'English'),
       ('VI', N'Tiếng Việt');


	   ALTER TABLE Settings
ADD CONSTRAINT FK_Settings_Languages
FOREIGN KEY (DefaultLanguage)
REFERENCES Languages(LangCode);


SELECT * FROM Languages;



SELECT DefaultLanguage FROM Settings;



UPDATE Settings
SET DefaultLanguage = 'VI', 
    LastUpdated = GETDATE()
WHERE SettingID = 1;


UPDATE Settings
SET DefaultLanguage = 'EN',
    LastUpdated = GETDATE()
WHERE SettingID = 1;


--ki?m tra còn m?c d?nh không
SELECT 
    c.name AS ColumnName,
    d.definition AS DefaultValue
FROM sys.columns c
LEFT JOIN sys.default_constraints d
    ON c.default_object_id = d.object_id
WHERE c.object_id = OBJECT_ID('Categories')
  AND c.name = 'VATRate';



  ALTER TABLE Categories
DROP CONSTRAINT DF__Categorie__VATRa__398D8EEE;  -- tên constraint c?a b?n



--Tìm tên DEFAULT constraint th?t
SELECT 
    d.name AS ConstraintName
FROM sys.default_constraints d
JOIN sys.columns c 
    ON d.parent_object_id = c.object_id 
   AND d.parent_column_id = c.column_id
WHERE c.object_id = OBJECT_ID('Categories')
  AND c.name = 'VATRate';




  CREATE PROCEDURE sp_settings_get
AS
BEGIN
    SELECT SettingID, VATRate, DefaultLanguage, LastUpdated
    FROM Settings;
END



CREATE PROCEDURE sp_settings_update
(
    @SettingID INT,
    @VATRate DECIMAL(5,2),
    @DefaultLanguage VARCHAR(5)
)
AS
BEGIN
    UPDATE Settings
    SET VATRate = @VATRate,
        DefaultLanguage = @DefaultLanguage,
        LastUpdated = GETDATE()
    WHERE SettingID = @SettingID;
END











-----------------------------------------------------
-- phần sờ tóc car
-----------------------------------------------------

IF OBJECT_ID('dbo.sp_report_revenue', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_report_revenue;
GO

IF OBJECT_ID('dbo.sp_report_revenue', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_report_revenue;
GO

CREATE PROCEDURE dbo.sp_report_revenue
(
    @FromDate DATETIME,
    @ToDate   DATETIME,
    @Option   NVARCHAR(10)  -- 'DAY' | 'MONTH'
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ToDateEnd DATETIME = DATEADD(DAY, 1, CAST(@ToDate AS DATETIME));

    ----------------------------------------------------------------------
    -- 1. ReceiptBase: tập IN
    ----------------------------------------------------------------------
    ;WITH ReceiptBase AS
    (
        SELECT 
            grd.ProductID,
            grd.ProductName,
            gr.ReceiptID,
            gr.ReceiptDate,
            gr.BatchNo,
            CAST(grd.Quantity AS DECIMAL(18,4)) AS QtyIn,
            grd.UnitPrice
        FROM GoodsReceipts gr
        INNER JOIN GoodsReceiptDetails grd 
            ON gr.ReceiptID = grd.ReceiptID
        WHERE gr.ReceiptDate < @ToDateEnd
    ),
    ReceiptRanges AS
    (
        SELECT 
            rb.*,
            SUM(rb.QtyIn) OVER (
                PARTITION BY rb.ProductID
                ORDER BY rb.ReceiptDate, rb.ReceiptID
            ) AS CumIn,
            SUM(rb.QtyIn) OVER (
                PARTITION BY rb.ProductID
                ORDER BY rb.ReceiptDate, rb.ReceiptID
            ) - rb.QtyIn AS CumInPrev
        FROM ReceiptBase rb
    ),

    ----------------------------------------------------------------------
    -- 2. SalesBase: tập OUT
    ----------------------------------------------------------------------
    SalesBase AS
    (
        SELECT 
            s.SaleID,
            s.SaleDate,
            si.ProductID,
            si.ProductName,
            CAST(si.Quantity AS DECIMAL(18,4)) AS QtyOut,
            si.UnitPrice,
            si.Discount
        FROM Sales s
        INNER JOIN SalesItems si 
            ON s.SaleID = si.SaleID
        WHERE s.SaleDate < @ToDateEnd
    ),
    SalesRanges AS
    (
        SELECT 
            sb.*,
            SUM(sb.QtyOut) OVER (
                PARTITION BY sb.ProductID
                ORDER BY sb.SaleDate, sb.SaleID
            ) AS CumOut,
            SUM(sb.QtyOut) OVER (
                PARTITION BY sb.ProductID
                ORDER BY sb.SaleDate, sb.SaleID
            ) - sb.QtyOut AS CumOutPrev
        FROM SalesBase sb
    ),

    ----------------------------------------------------------------------
    -- 3. FIFO Allocation
    ----------------------------------------------------------------------
    FifoAlloc AS
    (
        SELECT
            o.SaleID,
            o.SaleDate,
            o.ProductID,
            o.ProductName,
            i.ReceiptID,
            i.BatchNo,
            i.UnitPrice AS ReceiptUnitPrice,
            AllocQty =
                CASE WHEN
                    (CASE WHEN i.CumIn <= o.CumOut THEN i.CumIn ELSE o.CumOut END)
                    >
                    (CASE WHEN i.CumInPrev >= o.CumOutPrev THEN i.CumInPrev ELSE o.CumOutPrev END)
                THEN
                    (CASE WHEN i.CumIn <= o.CumOut THEN i.CumIn ELSE o.CumOut END)
                    -
                    (CASE WHEN i.CumInPrev >= o.CumOutPrev THEN i.CumInPrev ELSE o.CumOutPrev END)
                ELSE 0 END
        FROM SalesRanges o
        INNER JOIN ReceiptRanges i
            ON i.ProductID = o.ProductID
           AND i.CumIn     > o.CumOutPrev
           AND i.CumInPrev < o.CumOut
    ),

    FifoAllocFiltered AS
    (
        SELECT *
        FROM FifoAlloc
        WHERE AllocQty > 0
    ),

    ----------------------------------------------------------------------
    -- 4. COGS theo sale
    ----------------------------------------------------------------------
    CogsPerSale AS
    (
        SELECT 
            SaleID,
            SUM(AllocQty * ReceiptUnitPrice) AS COGS
        FROM FifoAllocFiltered
        GROUP BY SaleID
    ),

    ----------------------------------------------------------------------
    -- 5. Revenue theo sale
    ----------------------------------------------------------------------
    RevenuePerSale AS
    (
        SELECT 
            si.SaleID,
            SUM(si.Quantity * (si.UnitPrice - si.Discount)) AS Revenue
        FROM SalesItems si
        GROUP BY si.SaleID
    ),

    ----------------------------------------------------------------------
-- 6. Best Category (FIXED)
----------------------------------------------------------------------
BestCategory AS
(
    SELECT TOP 1
        c.CategoryID,
        c.CategoryName,
        SUM(si.Quantity) AS TotalQty
    FROM Sales s
    INNER JOIN SalesItems si ON s.SaleID = si.SaleID
    INNER JOIN Products p ON si.ProductID = p.ProductID
    INNER JOIN Categories c ON p.CategoryID = c.CategoryID
    WHERE CAST(s.SaleDate AS DATE) BETWEEN @FromDate AND @ToDate
    GROUP BY c.CategoryID, c.CategoryName
    ORDER BY TotalQty DESC
),


    ----------------------------------------------------------------------
    -- 7. Top Product
    ----------------------------------------------------------------------
    TopProduct AS
    (
        SELECT TOP 1
            si.ProductName,
            SUM(si.Quantity) AS TotalQty
        FROM Sales s
        INNER JOIN SalesItems si ON s.SaleID = si.SaleID
        WHERE CAST(s.SaleDate AS DATE) BETWEEN @FromDate AND @ToDate
        GROUP BY si.ProductName
        ORDER BY TotalQty DESC
    )
    SELECT
        CASE 
            WHEN @Option = 'DAY'   THEN CONVERT(NVARCHAR(10), CAST(s.SaleDate AS DATE), 23)
            WHEN @Option = 'MONTH' THEN FORMAT(s.SaleDate, 'yyyy-MM')
            ELSE CONVERT(NVARCHAR(10), CAST(s.SaleDate AS DATE), 23)
        END AS [Date],

        SUM(rps.Revenue) AS Revenue,
        SUM(rps.Revenue - ISNULL(cps.COGS, 0)) AS GrossProfit,

        -- KPI bổ sung
        (SELECT TOP 1 CategoryName FROM BestCategory) AS BestCategory,
        (SELECT TOP 1 ProductName FROM TopProduct) AS TopProduct

    FROM Sales s
    INNER JOIN RevenuePerSale rps ON s.SaleID = rps.SaleID
    LEFT JOIN  CogsPerSale     cps ON s.SaleID = cps.SaleID
    WHERE CAST(s.SaleDate AS DATE) BETWEEN @FromDate AND @ToDate
    GROUP BY
        CASE 
            WHEN @Option = 'DAY'   THEN CONVERT(NVARCHAR(10), CAST(s.SaleDate AS DATE), 23)
            WHEN @Option = 'MONTH' THEN FORMAT(s.SaleDate, 'yyyy-MM')
            ELSE CONVERT(NVARCHAR(10), CAST(s.SaleDate AS DATE), 23)
        END
    ORDER BY [Date];

END;
GO








IF OBJECT_ID('dbo.sp_report_import_export', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_report_import_export;
GO

IF OBJECT_ID('dbo.sp_report_import_export', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_report_import_export;
GO

CREATE PROCEDURE dbo.sp_report_import_export
(
    @FromDate DATETIME,
    @ToDate   DATETIME,
    @Option   NVARCHAR(10)   -- 'DAY' | 'MONTH'
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Chuẩn hoá option, nếu null thì mặc định = 'DAY'
    SET @Option = UPPER(ISNULL(@Option, 'DAY'));

    -- Lấy đến hết ngày @ToDate (dạng [ToDate, ToDateEnd) )
    DECLARE @ToDateEnd DATETIME = DATEADD(DAY, 1, CAST(@ToDate AS DATE));

    ----------------------------------------------------------------------
    -- 1) Import CTE
    ----------------------------------------------------------------------
    ;WITH ImportCTE AS
    (
        SELECT
            CONVERT(DATE, gr.ReceiptDate) AS [Date],
            grd.ProductID,
            grd.ProductName,
            SUM(grd.Quantity) AS ImportQty
        FROM GoodsReceipts gr
        INNER JOIN GoodsReceiptDetails grd 
            ON gr.ReceiptID = grd.ReceiptID
        WHERE gr.ReceiptDate >= @FromDate
          AND gr.ReceiptDate <  @ToDateEnd
        GROUP BY CONVERT(DATE, gr.ReceiptDate), grd.ProductID, grd.ProductName
    ),

    ----------------------------------------------------------------------
    -- 2) Export CTE
    ----------------------------------------------------------------------
    ExportCTE AS
    (
        SELECT
            CONVERT(DATE, s.SaleDate) AS [Date],
            si.ProductID,
            si.ProductName,
            SUM(si.Quantity) AS ExportQty
        FROM Sales s
        INNER JOIN SalesItems si
            ON s.SaleID = si.SaleID
        WHERE s.SaleDate >= @FromDate
          AND s.SaleDate <  @ToDateEnd
        GROUP BY CONVERT(DATE, s.SaleDate), si.ProductID, si.ProductName
    ),

    ----------------------------------------------------------------------
    -- 3) Merge Import & Export theo Ngày + Sản phẩm
    ----------------------------------------------------------------------
    Merged AS
    (
        SELECT
            COALESCE(i.[Date], e.[Date])          AS [Date],
            COALESCE(i.ProductID, e.ProductID)    AS ProductID,
            COALESCE(i.ProductName, e.ProductName) AS ProductName,
            ISNULL(i.ImportQty, 0) AS ImportQty,
            ISNULL(e.ExportQty, 0) AS ExportQty
        FROM ImportCTE i
        FULL OUTER JOIN ExportCTE e
            ON i.[Date]     = e.[Date]
           AND i.ProductID  = e.ProductID
    ),

    ----------------------------------------------------------------------
    -- 4) KPI tổng (tính một lần cho cả khoảng thời gian)
    ----------------------------------------------------------------------
    TotalStats AS
    (
        SELECT
            SUM(ImportQty) AS TotalImportQty,
            SUM(ExportQty) AS TotalExportQty
        FROM Merged
    ),

    ----------------------------------------------------------------------
    -- 5) KPI sản phẩm nhập nhiều / ít nhất
    ----------------------------------------------------------------------
    TopImport AS
    (
        SELECT TOP 1
            ProductName,
            SUM(ImportQty) AS Qty
        FROM Merged
        GROUP BY ProductName
        HAVING SUM(ImportQty) > 0          -- ⭐ BẮT BUỘC > 0
        ORDER BY Qty DESC
    ),
    LeastImport AS
    (
        SELECT TOP 1
            ProductName,
            SUM(ImportQty) AS Qty
        FROM Merged
        GROUP BY ProductName
        HAVING SUM(ImportQty) > 0          -- chỉ tính những sp có nhập
        ORDER BY Qty ASC
    ),

    ----------------------------------------------------------------------
    -- 6) KPI sản phẩm xuất nhiều / ít nhất
    ----------------------------------------------------------------------
    TopExport AS
    (
        SELECT TOP 1
            ProductName,
            SUM(ExportQty) AS Qty
        FROM Merged
        GROUP BY ProductName
        HAVING SUM(ExportQty) > 0          -- tránh chọn sản phẩm có 0 xuất
        ORDER BY Qty DESC
    ),
    LeastExport AS
    (
        SELECT TOP 1
            ProductName,
            SUM(ExportQty) AS Qty
        FROM Merged
        GROUP BY ProductName
        HAVING SUM(ExportQty) > 0          -- chỉ tính những sp có xuất
        ORDER BY Qty ASC
    )

    ----------------------------------------------------------------------
    -- 7) Kết quả cuối theo DAY hoặc MONTH
    ----------------------------------------------------------------------
    SELECT
        CASE 
            WHEN @Option = 'DAY'   THEN CONVERT(NVARCHAR(10), [Date], 23)   -- yyyy-MM-dd
            WHEN @Option = 'MONTH' THEN FORMAT([Date], 'yyyy-MM')           -- yyyy-MM
            ELSE CONVERT(NVARCHAR(10), [Date], 23)
        END AS [Date],

        SUM(ImportQty) AS ImportQty,
        SUM(ExportQty) AS ExportQty,

        -- KPI: lặp lại cho mỗi dòng (cùng giai đoạn)
        (SELECT TotalImportQty FROM TotalStats) AS TotalImportQty,
        (SELECT TotalExportQty FROM TotalStats) AS TotalExportQty,

        (SELECT TOP 1 ProductName FROM TopImport)   AS TopImportedProduct,
        (SELECT TOP 1 ProductName FROM LeastImport) AS LeastImportedProduct,
        (SELECT TOP 1 ProductName FROM TopExport)   AS TopExportedProduct,
        (SELECT TOP 1 ProductName FROM LeastExport) AS LeastExportedProduct

    FROM Merged
    GROUP BY
        CASE 
            WHEN @Option = 'DAY'   THEN CONVERT(NVARCHAR(10), [Date], 23)
            WHEN @Option = 'MONTH' THEN FORMAT([Date], 'yyyy-MM')
            ELSE CONVERT(NVARCHAR(10), [Date], 23)
        END
    ORDER BY [Date];
END;
GO






CREATE PROCEDURE dbo.sp_report_stock
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @AsOfDate DATE = CAST(GETDATE() AS DATE);
    DECLARE @AsOfDateEnd DATETIME = DATEADD(DAY, 1, @AsOfDate);

    ----------------------------------------------------------------------
    -- 1. Receipt (IN)
    ----------------------------------------------------------------------
    ;WITH ReceiptBase AS
    (
        SELECT 
            grd.ProductID,
            grd.ProductName,
            gr.ReceiptID,
            gr.ReceiptDate,
            gr.BatchNo,
            grd.UnitPrice,                    -- ⭐ giá nhập theo lô
            grd.ExpiryDate,                   -- ⭐ hạn dùng theo lô
            CAST(grd.Quantity AS INT) AS QtyIn
        FROM GoodsReceipts gr
        INNER JOIN GoodsReceiptDetails grd 
            ON gr.ReceiptID = grd.ReceiptID
        WHERE gr.ReceiptDate < @AsOfDateEnd
    ),
    ReceiptRanges AS
    (
        SELECT
            rb.*,
            SUM(rb.QtyIn) OVER (
                PARTITION BY rb.ProductID 
                ORDER BY rb.ReceiptDate, rb.ReceiptID
            ) AS CumIn,
            SUM(rb.QtyIn) OVER (
                PARTITION BY rb.ProductID 
                ORDER BY rb.ReceiptDate, rb.ReceiptID
            ) - rb.QtyIn AS CumInPrev
        FROM ReceiptBase rb
    ),

    ----------------------------------------------------------------------
    -- 2. Sales (OUT)
    ----------------------------------------------------------------------
    SalesBase AS
    (
        SELECT 
            si.ProductID,
            si.ProductName,
            s.SaleID,
            s.SaleDate,
            CAST(si.Quantity AS INT) AS QtyOut
        FROM SalesItems si
        INNER JOIN Sales s ON s.SaleID = si.SaleID
        WHERE s.SaleDate < @AsOfDateEnd
    ),
    SalesRanges AS
    (
        SELECT
            sb.*,
            SUM(sb.QtyOut) OVER (
                PARTITION BY sb.ProductID
                ORDER BY sb.SaleDate, sb.SaleID
            ) AS CumOut,
            SUM(sb.QtyOut) OVER (
                PARTITION BY sb.ProductID
                ORDER BY sb.SaleDate, sb.SaleID
            ) - sb.QtyOut AS CumOutPrev
        FROM SalesBase sb
    ),

    ----------------------------------------------------------------------
    -- 3. FIFO Allocation
    ----------------------------------------------------------------------
    FifoAlloc AS
    (
        SELECT
            o.ProductID,
            o.ProductName,
            i.ReceiptID,
            i.BatchNo,
            i.ReceiptDate,
            i.UnitPrice,
            i.ExpiryDate,

            AllocQty =
            CASE 
                WHEN 
                    (CASE WHEN i.CumIn <= o.CumOut THEN i.CumIn ELSE o.CumOut END)
                    >
                    (CASE WHEN i.CumInPrev >= o.CumOutPrev THEN i.CumInPrev ELSE o.CumOutPrev END)
                THEN 
                    (CASE WHEN i.CumIn <= o.CumOut THEN i.CumIn ELSE o.CumOut END)
                    -
                    (CASE WHEN i.CumInPrev >= o.CumOutPrev THEN i.CumInPrev ELSE o.CumOutPrev END)
                ELSE 0
            END
        FROM SalesRanges o
        INNER JOIN ReceiptRanges i
            ON i.ProductID = o.ProductID
           AND i.CumIn     > o.CumOutPrev
           AND i.CumInPrev < o.CumOut
    ),
    FifoFiltered AS
    (
        SELECT 
            ProductID,
            ReceiptID,
            CAST(AllocQty AS INT) AS AllocQty
        FROM FifoAlloc
        WHERE AllocQty > 0
    ),

    ----------------------------------------------------------------------
    -- 4. Tồn theo lô
    ----------------------------------------------------------------------
    StockByBatch AS
    (
        SELECT
            r.ProductID,
            r.ProductName,
            r.ReceiptID,
            r.BatchNo,
            r.ReceiptDate,
            r.UnitPrice,
            r.ExpiryDate,
            SUM(r.QtyIn) AS QtyIn,
            SUM(ISNULL(a.AllocQty, 0)) AS QtyAllocated
        FROM ReceiptBase r
        LEFT JOIN FifoFiltered a
            ON a.ProductID = r.ProductID
           AND a.ReceiptID = r.ReceiptID
        GROUP BY 
            r.ProductID,
            r.ProductName,
            r.ReceiptID,
            r.BatchNo,
            r.ReceiptDate,
            r.UnitPrice,
            r.ExpiryDate
    ),

    ----------------------------------------------------------------------
    -- 5. Bảng tồn có QtyRemain
    ----------------------------------------------------------------------
    StockFinal AS
    (
        SELECT
			p.ProductID,
			p.SKU,
			sb.ProductName,
			sb.BatchNo,
			sb.ReceiptDate AS FirstReceiptDate,
			sb.QtyIn,
			sb.QtyIn - sb.QtyAllocated AS QtyRemain,
			sb.UnitPrice,              -- ⭐ THÊM DÒNG NÀY
			sb.ExpiryDate,             -- ⭐ THÊM DÒNG NÀY
			DATEDIFF(DAY, sb.ReceiptDate, GETDATE()) AS AgeInDays,
			p.MinStock
		FROM StockByBatch sb
		JOIN Products p ON p.ProductID = sb.ProductID
		WHERE (sb.QtyIn - sb.QtyAllocated) > 0

    ),

    ----------------------------------------------------------------------
    -- 6. KPI
    ----------------------------------------------------------------------
    KPI AS
    (
        SELECT
            SUM(sf.QtyRemain * sf.UnitPrice) AS TotalStockValue,
            
            (SELECT COUNT(*)
             FROM (
                 SELECT ProductID, SUM(QtyRemain) AS TotalRemain
                 FROM StockFinal
                 GROUP BY ProductID
             ) x
             JOIN Products p ON p.ProductID = x.ProductID
             WHERE x.TotalRemain < p.MinStock) AS LowStockCount,

            MIN(DATEDIFF(DAY, @AsOfDate, sf.ExpiryDate)) AS MinDaysToExpire
        FROM StockFinal sf
    )

    ----------------------------------------------------------------------
    -- 7. OUTPUT CUỐI
    ----------------------------------------------------------------------
    SELECT
        sf.ProductID,
        p.SKU,
        sf.ProductName,
        sf.BatchNo,
        sf.FirstReceiptDate AS FirstReceiptDate,
        sf.QtyIn,
        sf.QtyRemain,
		sf.UnitPrice,       -- ⭐ THÊM
		sf.ExpiryDate, 
        DATEDIFF(DAY, sf.FirstReceiptDate, GETDATE()) AS AgeInDays,
        p.MinStock,

        -- KPI gắn vào mọi dòng cho dễ đọc FE
        k.TotalStockValue,
        k.LowStockCount,
        k.MinDaysToExpire

    FROM StockFinal sf
    JOIN Products p ON p.ProductID = sf.ProductID
    CROSS JOIN KPI k
    ORDER BY sf.ProductName, sf.FirstReceiptDate;

END;
GO










USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_user_get_by_username_password]    Script Date: 11/21/2025 9:26:47 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
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