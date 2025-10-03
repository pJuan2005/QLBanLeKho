create database QuanLyKho
use  QuanLyKho

drop database QuanLyKho

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
	Image NVARCHAR(255),
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
    SaleDate DATE NOT NULL, -- Ngày bán
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
INSERT INTO Categories (CategoryName, Description)
VALUES
(N'Giày Thể Thao', N'Các loại giày thể thao nam nữ'),
(N'Sandal', N'Sandal thời trang'),
(N'Dép', N'Dép đi trong nhà và ngoài trời'),
(N'Giày Tây', N'Giày công sở nam'),
(N'Giày Cao Gót', N'Giày cho nữ giới'),
(N'Giày Boot', N'Giày mùa đông'),
(N'Giày Sneaker', N'Giày phong cách trẻ trung'),
(N'Giày Chạy Bộ', N'Giày cho vận động viên'),
(N'Giày Leo Núi', N'Giày chuyên dụng leo núi'),
(N'Giày Lười', N'Giày không cần buộc dây'),
(N'Giày Tennis', N'Giày đánh tennis'),
(N'Giày Golf', N'Giày chơi golf'),
(N'Giày Bóng Đá', N'Giày đá bóng'),
(N'Giày Bóng Rổ', N'Giày chơi bóng rổ'),
(N'Giày Thời Trang', N'Giày phong cách cá nhân');

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

-- PRODUCTS (15 bản ghi)
INSERT INTO Products (SKU, Barcode, ProductName, CategoryID, SupplierID, Unit, Price, MinStock, Status,Image)
VALUES
('SKU001', 'BC001', N'Giày Sneaker Trắng', 1, 1, N'Đôi', 800000, 10, 'Active', N'Ảnh 1'),
('SKU002', 'BC002', N'Giày Sneaker Đen', 1, 2, N'Đôi', 850000, 10, 'Active', N'Ảnh 1'),
('SKU003', 'BC003', N'Giày Chạy Bộ Nam', 8, 3, N'Đôi', 1200000, 5, 'Active', N'Ảnh 1'),
('SKU004', 'BC004', N'Giày Chạy Bộ Nữ', 8, 4, N'Đôi', 1150000, 5, 'Active', N'Ảnh 1'),
('SKU005', 'BC005', N'Giày Tennis Trắng', 11, 5, N'Đôi', 950000, 3, 'Active', N'Ảnh 1'),
('SKU006', 'BC006', N'Giày Bóng Đá Cỏ Tự Nhiên', 13, 6, N'Đôi', 1350000, 7, 'Active', N'Ảnh 1'),
('SKU007', 'BC007', N'Giày Bóng Đá Cỏ Nhân Tạo', 13, 7, N'Đôi', 1100000, 7, 'Active', N'Ảnh 1'),
('SKU008', 'BC008', N'Giày Bóng Rổ Cao Cổ', 14, 8, N'Đôi', 1400000, 6, 'Active', N'Ảnh 1'),
('SKU009', 'BC009', N'Giày Golf Chống Thấm', 12, 9, N'Đôi', 2500000, 2, 'Active', N'Ảnh 1'),
('SKU010', 'BC010', N'Giày Tây Nam', 4, 10, N'Đôi', 1600000, 4, 'Active', N'Ảnh 1'),
('SKU011', 'BC011', N'Giày Cao Gót Đen', 5, 11, N'Đôi', 900000, 3, 'Active', N'Ảnh 1'),
('SKU012', 'BC012', N'Giày Boot Da', 6, 12, N'Đôi', 2200000, 2, 'Active', N'Ảnh 1'),
('SKU013', 'BC013', N'Dép Lê Nam', 3, 13, N'Đôi', 150000, 20, 'Active', N'Ảnh 1'),
('SKU014', 'BC014', N'Sandal Nữ Thời Trang', 2, 14, N'Đôi', 350000, 15, 'Active', N'Ảnh 1'),
('SKU015', 'BC015', N'Giày Lười Nam', 10, 15, N'Đôi', 780000, 8, 'Active', N'Ảnh 1');





INSERT INTO PurchaseOrders (SupplierID, OrderDate, TotalAmount, Status)
VALUES
(1, '2025-01-22', 5000000, 'Completed'),
(2, '2025-02-25', 4500000, 'Completed'),
(3, '2025-03-23', 7000000, 'Pending'),
(4, '2025-03-26', 3200000, 'Completed'),
(5, '2025-04-21', 2500000, 'Pending'),
(6, '2025-05-22', 6000000, 'Completed'),
(7, '2025-06-28', 4000000, 'Pending'),
(8, '2025-07-27', 5500000, 'Completed'),
(9, '2025-07-25', 4200000, 'Completed'),
(10, '2025-08-26', 3800000, 'Pending'),
(11, '2025-09-29', 4900000, 'Completed'),
(12, '2025-10-30', 5200000, 'Pending'),
(13, '2025-11-20', 6100000, 'Completed'),
(14, '2025-11-27', 3000000, 'Completed'),
(15, '2025-12-23', 4500000, 'Pending');





INSERT INTO PurchaseOrderDetails (POID, ProductID, NameProduct, Quantity, UnitPrice)
VALUES
(1, 1, N'Giày Sneaker Trắng', 50, 600000),
(1, 2, N'Giày Sneaker Đen', 40, 650000),
(2, 3, N'Giày Chạy Bộ Nam', 30, 900000),
(2, 4, N'Giày Chạy Bộ Nữ', 25, 880000),
(3, 5, N'Giày Tennis Trắng', 20, 700000),
(3, 6, N'Giày Bóng Đá Cỏ Tự Nhiên', 15, 1100000),
(4, 7, N'Giày Bóng Đá Cỏ Nhân Tạo', 20, 900000),
(5, 8, N'Giày Bóng Rổ Cao Cổ', 15, 1200000),
(6, 9, N'Giày Golf Chống Thấm', 10, 2000000),
(7, 10, N'Giày Tây Nam', 20, 1300000),
(8, 11, N'Giày Cao Gót Đen', 25, 700000),
(9, 12, N'Giày Boot Da', 12, 1800000),
(10, 13, N'Dép Lê Nam', 40, 100000),
(11, 14, N'Sandal Nữ Thời Trang', 35, 250000),
(12, 15, N'Giày Lười Nam', 30, 600000);


select * from PurchaseOrderDetails


INSERT INTO GoodsReceipts (POID, ReceiptDate, TotalAmount)
VALUES
(1, '2025-01-12', 5000000),
(2, '2025-01-04', 4500000),
(3, '2025-01-18', 7000000),
(4, '2025-01-11', 3200000),
(5, '2025-01-18', 2500000),
(6, '2025-01-03', 6000000),
(7, '2025-01-17', 4000000),
(8, '2025-01-04', 5500000),
(9, '2025-01-12', 4200000),
(10, '2025-01-01', 3800000),
(11, '2025-01-06', 4900000),
(12, '2025-01-14', 5200000),
(13, '2025-01-19', 6100000),
(14, '2025-01-05', 3000000),
(15, '2025-01-09', 4500000);





INSERT INTO GoodsReceiptDetails (ReceiptID, ProductID, Quantity, UnitPrice, BatchNo, ExpiryDate)
VALUES
(1, 1, 50, 600000, 'B001', '2026-01-01'),
(2, 2, 40, 650000, 'B002', '2026-01-02'),
(3, 3, 30, 900000, 'B003', '2026-01-03'),
(4, 4, 25, 880000, 'B004', '2026-01-04'),
(5, 5, 20, 700000, 'B005', '2026-01-05'),
(6, 6, 15, 1100000, 'B006', '2026-01-06'),
(7, 7, 20, 900000, 'B007', '2026-01-07'),
(8, 8, 15, 1200000, 'B008', '2026-01-08'),
(9, 9, 10, 2000000, 'B009', '2026-01-09'),
(10, 10, 20, 1300000, 'B010', '2026-01-10'),
(11, 11, 25, 700000, 'B011', '2026-01-11'),
(12, 12, 12, 1800000, 'B012', '2026-01-12'),
(13, 13, 40, 100000, 'B013', '2026-01-13'),
(14, 14, 35, 250000, 'B014', '2026-01-14'),
(15, 15, 30, 600000, 'B015', '2026-01-15');





INSERT INTO Promotions (PromotionName, Type, Value, StartDate, EndDate, ProductGroup)
VALUES
(N'Giảm 10% Toàn Bộ Sneaker', 'Percent', 10, '2025-02-01', '2025-02-15', N'Sneaker'),
(N'Giảm 200K Giày Tây', 'Value', 200000, '2025-02-05', '2025-02-20', N'Giày Tây'),
(N'Mua 1 Tặng 1 Sandal', 'Percent', 50, '2025-02-10', '2025-02-25', N'Sandal'),
(N'Giảm 15% Giày Bóng Đá', 'Percent', 15, '2025-03-01', '2025-03-15', N'Giày Bóng Đá'),
(N'Giảm 100K Giày Cao Gót', 'Value', 100000, '2025-03-05', '2025-03-20', N'Giày Cao Gót'),
(N'Giảm 20% Giày Boot', 'Percent', 20, '2025-03-10', '2025-03-25', N'Giày Boot'),
(N'Giảm 10% Giày Chạy Bộ', 'Percent', 10, '2025-04-01', '2025-04-15', N'Giày Chạy Bộ'),
(N'Giảm 15% Giày Golf', 'Percent', 15, '2025-04-05', '2025-04-20', N'Giày Golf'),
(N'Giảm 50K Dép', 'Value', 50000, '2025-04-10', '2025-04-25', N'Dép'),
(N'Giảm 5% Toàn Bộ', 'Percent', 5, '2025-05-01', '2025-05-15', N'Tất cả'),
(N'Giảm 10% Giày Tennis', 'Percent', 10, '2025-05-05', '2025-05-20', N'Giày Tennis'),
(N'Giảm 7% Giày Bóng Rổ', 'Percent', 7, '2025-05-10', '2025-05-25', N'Giày Bóng Rổ'),
(N'Giảm 300K Giày Lười', 'Value', 300000, '2025-06-01', '2025-06-15', N'Giày Lười'),
(N'Giảm 8% Giày Thể Thao', 'Percent', 8, '2025-06-05', '2025-06-20', N'Giày Thể Thao'),
(N'Giảm 20% Clearance', 'Percent', 20, '2025-06-10', '2025-06-30', N'Hàng xả kho');




INSERT INTO Sales (CustomerID, UserID, SaleDate, TotalAmount, VATAmount, PromotionID, PaymentStatus)
VALUES
(1, 2, '2025-02-01', 2000000, 200000, 1, 'Paid'),
(2, 3, '2025-02-02', 1500000, 150000, 2, 'Unpaid'),
(3, 4, '2025-02-03', 2500000, 250000, 3, 'Paid'),
(4, 5, '2025-02-04', 1800000, 180000, 4, 'Paid'),
(5, 6, '2025-02-05', 1200000, 120000, NULL, 'Unpaid'),
(6, 7, '2025-02-06', 3000000, 300000, 5, 'Paid'),
(7, 8, '2025-02-07', 2200000, 220000, 6, 'Paid'),
(8, 9, '2025-02-08', 2800000, 280000, 7, 'Unpaid'),
(9, 10, '2025-02-09', 3500000, 350000, 8, 'Paid'),
(10, 11, '2025-02-10', 4000000, 400000, 9, 'Paid'),
(11, 12, '2025-02-11', 2700000, 270000, 10, 'Unpaid'),
(12, 13, '2025-02-12', 5000000, 500000, 11, 'Paid'),
(13, 14, '2025-02-13', 3200000, 320000, 12, 'Paid'),
(14, 15, '2025-02-14', 1500000, 150000, 13, 'Unpaid'),
(15, 1, '2025-02-15', 1800000, 180000, 14, 'Paid');





INSERT INTO SalesItems (SaleID, ProductID, Quantity, UnitPrice, Discount)
VALUES
(1, 1, 2, 800000, 0),
(2, 2, 1, 850000, 50000),
(3, 3, 2, 1200000, 0),
(4, 4, 1, 1150000, 150000),
(5, 5, 1, 950000, 0),
(6, 6, 2, 1350000, 200000),
(7, 7, 1, 1100000, 0),
(8, 8, 1, 1400000, 100000),
(9, 9, 1, 2500000, 0),
(10, 10, 2, 1600000, 0),
(11, 11, 1, 900000, 50000),
(12, 12, 1, 2200000, 0),
(13, 13, 3, 150000, 0),
(14, 14, 2, 350000, 50000),
(15, 15, 1, 780000, 0);




INSERT INTO Returns (SaleID, CustomerID, ReturnDate, Reason)
VALUES
(1, 1, '2025-02-16', N'Lỗi sản phẩm'),
(2, 2, '2025-02-17', N'Không vừa size'),
(3, 3, '2025-02-18', N'Giao nhầm mẫu'),
(4, 4, '2025-02-19', N'Sản phẩm trầy xước'),
(5, 5, '2025-02-20', N'Khách đổi ý'),
(6, 6, '2025-02-21', N'Không hài lòng'),
(7, 7, '2025-02-22', N'Lỗi keo dán'),
(8, 8, '2025-02-23', N'Hết nhu cầu'),
(9, 9, '2025-02-24', N'Không hợp màu'),
(10, 10, '2025-02-25', N'Không đúng chất liệu'),
(11, 11, '2025-02-26', N'Khách hủy đơn'),
(12, 12, '2025-02-27', N'Sản phẩm quá chật'),
(13, 13, '2025-02-28', N'Sản phẩm quá rộng'),
(14, 14, '2025-03-01', N'Lỗi đế giày'),
(15, 15, '2025-03-02', N'Khách không thích');




INSERT INTO Invoices (SaleID, InvoiceNo, InvoiceDate, TotalAmount, VATAmount)
VALUES
(1, 'INV001', '2025-02-16', 2000000, 200000),
(2, 'INV002', '2025-02-17', 1500000, 150000),
(3, 'INV003', '2025-02-18', 2500000, 250000),
(4, 'INV004', '2025-02-19', 1800000, 180000),
(5, 'INV005', '2025-02-20', 1200000, 120000),
(6, 'INV006', '2025-02-21', 3000000, 300000),
(7, 'INV007', '2025-02-22', 2200000, 220000),
(8, 'INV008', '2025-02-23', 2800000, 280000),
(9, 'INV009', '2025-02-24', 3500000, 350000),
(10, 'INV010', '2025-02-25', 4000000, 400000),
(11, 'INV011', '2025-02-26', 2700000, 270000),
(12, 'INV012', '2025-02-27', 5000000, 500000),
(13, 'INV013', '2025-02-28', 3200000, 320000),
(14, 'INV014', '2025-03-01', 1500000, 150000),
(15, 'INV015', '2025-03-02', 1800000, 180000);





INSERT INTO Payments (CustomerID, SupplierID, Amount, PaymentDate, Method)
VALUES
(1, NULL, 2000000, '2025-02-16', N'Tiền mặt'),
(2, NULL, 1500000, '2025-02-17', N'Chuyển khoản'),
(3, NULL, 2500000, '2025-02-18', N'Thẻ tín dụng'),
(4, NULL, 1800000, '2025-02-19', N'Tiền mặt'),
(5, NULL, 1200000, '2025-02-20', N'Ví điện tử'),
(NULL, 1, 3000000, '2025-02-21', N'Chuyển khoản'),
(NULL, 2, 2200000, '2025-02-22', N'Tiền mặt'),
(NULL, 3, 2800000, '2025-02-23', N'Chuyển khoản'),
(6, NULL, 3500000, '2025-02-24', N'Thẻ tín dụng'),
(7, NULL, 4000000, '2025-02-25', N'Tiền mặt'),
(NULL, 4, 2700000, '2025-02-26', N'Chuyển khoản'),
(8, NULL, 5000000, '2025-02-27', N'Thẻ tín dụng'),
(NULL, 5, 3200000, '2025-02-28', N'Tiền mặt'),
(9, NULL, 1500000, '2025-03-01', N'Ví điện tử'),
(NULL, 6, 1800000, '2025-03-02', N'Chuyển khoản');




INSERT INTO StockCards (ProductID, TransactionType, Quantity, Balance, RefID, TransactionDate)
VALUES
(1, 'IN', 50, 50, 1, '2025-01-16'),
(2, 'IN', 40, 40, 2, '2025-01-17'),
(3, 'IN', 30, 30, 3, '2025-01-18'),
(4, 'IN', 25, 25, 4, '2025-01-19'),
(5, 'IN', 20, 20, 5, '2025-01-20'),
(6, 'IN', 15, 15, 6, '2025-01-21'),
(7, 'IN', 20, 20, 7, '2025-01-22'),
(8, 'IN', 15, 15, 8, '2025-01-23'),
(9, 'IN', 10, 10, 9, '2025-01-24'),
(10, 'IN', 20, 20, 10, '2025-01-25'),
(1, 'OUT', 5, 45, 1, '2025-02-01'),
(2, 'OUT', 3, 37, 2, '2025-02-02'),
(3, 'OUT', 2, 28, 3, '2025-02-03'),
(4, 'OUT', 1, 24, 4, '2025-02-04'),
(5, 'OUT', 2, 18, 5, '2025-02-05');










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
    @Status NVARCHAR(20) = 'Active',
	@Image NVARCHAR(255) = NULL  -- 🆕
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
        Status,
		Image
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
        @Status,
		@Image
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
    @Status      NVARCHAR(20) = NULL,
	@Image       NVARCHAR(255) = NULL
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
        Status      = IIF(@Status IS NULL, Status, @Status),
		Image       = IIF(@Image IS NULL, Image, @Image)
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
               p.Status,
			   p.Image
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
               p.Status,
			   p.Image
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




EXEC sp_product_delete @ProductID = 16;


DROP PROCEDURE [dbo].[sp_product_delete];





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


create procedure [dbo].[sp_category_get_by_id](@CategoryID int)
as
begin
select * from Categories where CategoryID = @CategoryID;
end;
GO


USE [QLBanLeKho]
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
    @TransactionType NVARCHAR(10),  -- IN/OUT
    @Quantity        INT,
    @Balance         INT,
    @RefID           INT = NULL,
    @TransactionDate DATETIME
)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO StockCards
    (
        ProductID,
        TransactionType,
        Quantity,
        Balance,
        RefID,
        TransactionDate
    )
    VALUES
    (
        @ProductID,
        @TransactionType,
        @Quantity,
        @Balance,
        @RefID,
        @TransactionDate
    );

    SELECT SCOPE_IDENTITY() AS NewStockID;
END;
GO



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
    @RefID           INT = NULL,
    @TransactionDate DATETIME = NULL
)
AS
BEGIN
    UPDATE StockCards
    SET
        ProductID       = ISNULL(@ProductID, ProductID),
        TransactionType = ISNULL(@TransactionType, TransactionType),
        Quantity        = ISNULL(@Quantity, Quantity),
        Balance         = ISNULL(@Balance, Balance),
        RefID           = ISNULL(@RefID, RefID),
        TransactionDate = ISNULL(@TransactionDate, TransactionDate)
        
    WHERE StockID = @StockID;

    SELECT '' ;
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

    DELETE FROM StockCards
    WHERE StockID = @StockID;

    SELECT 'Xóa thẻ kho thành công' AS Message;
END;
GO



EXEC sp_stockcard_delete @StockID = 12;

-- =============================================
-- Tìm kiếm & phân trang thẻ kho
-- =============================================
CREATE PROCEDURE [dbo].[sp_stockcard_search]
(
    @page_index      INT,
    @page_size       INT,
    @StockID         INT = NULL,
    @ProductID       INT = NULL,
    @TransactionType NVARCHAR(10) = '',
    @RefID           INT = NULL,
    @Status          NVARCHAR(20) = '',
    @option          VARCHAR(50) = ''
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
                          WHEN @option = 'DATE' THEN sc.TransactionDate
                          WHEN @option = 'QTY' THEN sc.Quantity
                          ELSE sc.StockID
                      END ASC)) AS RowNumber,
               sc.*
        INTO #Results1
        FROM StockCards AS sc
        WHERE (@StockID IS NULL OR sc.StockID = @StockID)
          AND (@ProductID IS NULL OR sc.ProductID = @ProductID)
          AND (@TransactionType = '' OR sc.TransactionType = @TransactionType)
          AND (@RefID IS NULL OR sc.RefID = @RefID)

        SELECT @RecordCount = COUNT(*) FROM #Results1;

        SELECT *, @RecordCount AS RecordCount
        FROM #Results1
        WHERE RowNumber BETWEEN(@page_index - 1) * @page_size + 1 
                            AND (@page_index * @page_size)
           OR @page_index = -1;

        DROP TABLE #Results1;
    END
    ELSE
    BEGIN
        SET NOCOUNT ON;

        SELECT (ROW_NUMBER() OVER(
                  ORDER BY 
                      CASE 
                          WHEN @option = 'DATE' THEN sc.TransactionDate
                          WHEN @option = 'QTY' THEN sc.Quantity
                          ELSE sc.StockID
                      END ASC)) AS RowNumber,
               sc.*
        INTO #Results2
        FROM StockCards AS sc
        WHERE (@StockID IS NULL OR sc.StockID = @StockID)
          AND (@ProductID IS NULL OR sc.ProductID = @ProductID)
          AND (@TransactionType = '' OR sc.TransactionType = @TransactionType)
          AND (@RefID IS NULL OR sc.RefID = @RefID)

        SELECT @RecordCount = COUNT(*) FROM #Results2;

        SELECT *, @RecordCount AS RecordCount
        FROM #Results2;

        DROP TABLE #Results2;
    END;
END;
GO



-- =============================================
-- Báo cáo doanh thu & lợi nhuận gộp
-- =============================================
CREATE PROCEDURE [dbo].[sp_report_revenue]
(
    @FromDate DATETIME,
    @ToDate DATETIME,
    @Option VARCHAR(20) = 'DAY'  -- DAY | MONTH | SHIFT
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Giả sử doanh thu nằm ở bảng HoaDon (Invoices) và ChiTietHoaDon (InvoiceDetails)
    -- Các cột: InvoiceDate, Quantity, UnitPrice, TotalAmount, CostPrice

    SELECT
        CASE 
            WHEN @Option = 'DAY'   THEN CAST(CONVERT(DATE, hd.InvoiceDate) AS NVARCHAR)
            WHEN @Option = 'MONTH' THEN FORMAT(hd.InvoiceDate, 'yyyy-MM')
            WHEN @Option = 'SHIFT' THEN CONCAT(CONVERT(DATE, hd.InvoiceDate), ' - Ca ', hd.ShiftID)
            ELSE CAST(CONVERT(DATE, hd.InvoiceDate) AS NVARCHAR)
        END AS DateLabel,
        SUM(ct.Quantity * ct.UnitPrice) AS Revenue,
        SUM((ct.UnitPrice - ct.UnitPrice) * ct.Quantity) AS GrossProfit
    FROM Invoices hd
    INNER JOIN InvoiceDetails ct ON hd.InvoiceID = ct.InvoiceID
    WHERE hd.InvoiceDate BETWEEN @FromDate AND @ToDate
    GROUP BY 
        CASE 
            WHEN @Option = 'DAY'   THEN CAST(CONVERT(DATE, hd.InvoiceDate) AS NVARCHAR)
            WHEN @Option = 'MONTH' THEN FORMAT(hd.InvoiceDate, 'yyyy-MM')
            WHEN @Option = 'SHIFT' THEN CONCAT(CONVERT(DATE, hd.InvoiceDate), ' - Ca ', hd.ShiftID)
            ELSE CAST(CONVERT(DATE, hd.InvoiceDate) AS NVARCHAR)
        END
    ORDER BY MIN(hd.InvoiceDate);
END;
GO


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
CREATE PROCEDURE [dbo].[sp_report_import_export]
(
    @FromDate DATETIME,
    @ToDate DATETIME
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Giả sử nhập nằm ở bảng PhieuNhap + ChiTietPhieuNhap
    -- Xuất nằm ở bảng HoaDon + ChiTietHoaDon

    SELECT 
        d.DateValue,
        ISNULL(SUM(d.ImportQty), 0) AS ImportQty,
        ISNULL(SUM(d.ExportQty), 0) AS ExportQty
    FROM
    (
        -- Nhập
        SELECT CONVERT(DATE, pn.NgayNhap) AS DateValue, SUM(ct.SoLuong) AS ImportQty, 0 AS ExportQty
        FROM PhieuNhap pn
        INNER JOIN ChiTietPhieuNhap ct ON pn.PhieuNhapID = ct.PhieuNhapID
        WHERE pn.NgayNhap BETWEEN @FromDate AND @ToDate
        GROUP BY CONVERT(DATE, pn.NgayNhap)

        UNION ALL

        -- Xuất (bán hàng)
        SELECT CONVERT(DATE, hd.InvoiceDate) AS DateValue, 0 AS ImportQty, SUM(ct.Quantity) AS ExportQty
        FROM Invoices hd
        INNER JOIN InvoiceDetails ct ON hd.InvoiceID = ct.InvoiceID
        WHERE hd.InvoiceDate BETWEEN @FromDate AND @ToDate
        GROUP BY CONVERT(DATE, hd.InvoiceDate)
    ) d
    GROUP BY d.DateValue
    ORDER BY d.DateValue;
END;
GO


drop PROCEDURE [dbo].[sp_report_import_export]



--2
CREATE OR ALTER PROCEDURE [dbo].[sp_report_import_export] -- Dùng CREATE OR ALTER để có thể chạy lại mà không cần xóa SP cũ
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
-- Tìm kiếm & phân trang thẻ kho
-- =============================================








-- =============================================
-- Tìm kiếm & phân trang thẻ kho
-- =============================================








-- =============================================
-- Tìm kiếm & phân trang thẻ kho
-- =============================================








-- =============================================
-- Tìm kiếm & phân trang thẻ kho
-- =============================================






-- =============================================
-- Tìm kiếm & phân trang thẻ kho
-- =============================================

DROP PROCEDURE [dbo].[sp_BaoCaoDoanhThu]


CREATE OR ALTER PROCEDURE sp_BaoCaoDoanhThu
    @option NVARCHAR(10),       -- 'Ngay' | 'Thang' | 'Khoang'
    @Ngay DATE = NULL,          -- dùng cho option = 'Ngay'
    @Nam INT = NULL,            -- dùng cho option = 'Thang'
    @Thang INT = NULL,          -- dùng cho option = 'Thang'
    @TuNgay DATE = NULL,        -- dùng cho option = 'Khoang'
    @DenNgay DATE = NULL        -- dùng cho option = 'Khoang'
AS
BEGIN
    SET NOCOUNT ON;

    -- Chuẩn hóa option về chữ hoa
    SET @option = UPPER(LTRIM(RTRIM(@option)));

    IF @option = 'NGAY'
    BEGIN
        SELECT 
            CAST(S.SaleDate AS DATE) AS Ngay,
            SUM(SI.Quantity * SI.UnitPrice) AS TienHang,
            SUM(SI.Discount) AS TongGiamGia,
            SUM(S.VATAmount) AS VAT,
            SUM(S.TotalAmount) AS TongTien
        FROM Sales S
        INNER JOIN SalesItems SI ON S.SaleID = SI.SaleID
        WHERE CAST(S.SaleDate AS DATE) = @Ngay
        GROUP BY CAST(S.SaleDate AS DATE);
    END
    ELSE IF @option = 'THANG'
    BEGIN
        SELECT 
            YEAR(S.SaleDate) AS Nam,
            MONTH(S.SaleDate) AS Thang,
            SUM(SI.Quantity * SI.UnitPrice) AS TienHang,
            SUM(SI.Discount) AS TongGiamGia,
            SUM(S.VATAmount) AS VAT,
            SUM(S.TotalAmount) AS TongTien
        FROM Sales S
        INNER JOIN SalesItems SI ON S.SaleID = SI.SaleID
        WHERE YEAR(S.SaleDate) = @Nam AND MONTH(S.SaleDate) = @Thang
        GROUP BY YEAR(S.SaleDate), MONTH(S.SaleDate);
    END
    ELSE IF @option = 'KHOANG'
    BEGIN
        SELECT 
            CAST(S.SaleDate AS DATE) AS Ngay,
            SUM(SI.Quantity * SI.UnitPrice) AS TienHang,
            SUM(SI.Discount) AS TongGiamGia,
            SUM(S.VATAmount) AS VAT,
            SUM(S.TotalAmount) AS TongTien
        FROM Sales S
        INNER JOIN SalesItems SI ON S.SaleID = SI.SaleID
        WHERE CAST(S.SaleDate AS DATE) BETWEEN @TuNgay AND @DenNgay
        GROUP BY CAST(S.SaleDate AS DATE)
        ORDER BY Ngay;
    END
    ELSE
    BEGIN
        RAISERROR('Gia tri @option khong hop le. Dung ''Ngay'', ''Thang'' hoac ''Khoang''.', 16, 1);
    END
END;
GO




EXEC sp_BaoCaoDoanhThu @option = 'Ngay', @Ngay = '2025-09-12';
EXEC sp_BaoCaoDoanhThu @option = 'Thang', @Nam = 2025, @Thang = 9;
EXEC sp_BaoCaoDoanhThu @option = 'Khoang', @TuNgay = '2025-09-01', @DenNgay = '2025-09-15';





SELECT 
    s.SaleID,
    SUM(si.Quantity * si.UnitPrice - si.Discount) AS Revenue,
    SUM(si.Quantity * avgc.AvgCost) AS COGS,
    SUM(si.Quantity * si.UnitPrice - si.Discount) - SUM(si.Quantity * avgc.AvgCost) AS Profit
FROM SalesItems si
JOIN Sales s ON si.SaleID = s.SaleID
JOIN (
    SELECT 
        gr.ProductID,
        SUM(gr.Quantity * gr.UnitPrice) * 1.0 / NULLIF(SUM(gr.Quantity),0) AS AvgCost
    FROM GoodsReceiptDetails gr
    GROUP BY gr.ProductID
) avgc ON si.ProductID = avgc.ProductID
GROUP BY s.SaleID;
