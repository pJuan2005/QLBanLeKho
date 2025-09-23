create database QLBanLeKho
use QLBanLeKho

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


--test dữ liệu


INSERT INTO Suppliers (SupplierName, Address, Phone, Email)
VALUES (N'Công ty TNHH Minh Phát', N'123 Đường Lê Lợi, Hải Phòng', '0905123456', N'minhphat@supplier.vn');




--Stored procedure thêm (create) đơn mua hàng  vào bảng đơn mua hàng
go
create procedure [dbo].[sp_PurchaseOrders_create]
(
@SupplierID int,
@OrderDate  date,
@TotalAmount  decimal(18,2),
@Status nvarchar(20))
as
begin
insert into PurchaseOrders
( SupplierID, OrderDate, TotalAmount, Status)
values
( @SupplierID, @OrderDate, @TotalAmount, @Status);
select '';
end;
go


--Stored procedure sửa (update) đơn mua hàng vào bảng đơn mua hàng
go
create procedure [dbo].[sp_PurchaseOrders_update]
(@POID INT,
@SupplierID int,
@OrderDate  date,
@TotalAmount  decimal(18,2),
@Status nvarchar(20))
as
begin
update PurchaseOrders
set
SupplierID = @SupplierID ,
OrderDate  = @OrderDate ,
TotalAmount  = @TotalAmount ,
Status  = @Status 
where POID = @POID;
select '';
end;
go

--Stored procedure xoá (delete) đơn mua hàng vào bảng đơn mua hàng
create procedure  [dbo].[sp_PurchaseOrders_delete]
(@POID int)
as
begin delete from PurchaseOrders
where POID = @POID
select '';
end;

--Stored procedure tìm kiếm (search) tìm kiếm theo tiêu chí SupplierID, OrderDate, TotalAmount từ bảng đơn mua hàng
go
create procedure [dbo].[sp_PurchaseOrders_get_by_id]
(@POID int)
as
begin
select *
from PurchaseOrders
where POID = @POID;
end;
go

--Stored procedure truy vấn (select) đơn mua hàng từ bảng đơn mua hàng
create procedure [dbo].[sp_PurchaseOrders_search]
(
@page_index INT,
@page_size INT,
@SupplierID INT = NULL,
@OrderDate DATE = NULL,
@TotalAmount DECIMAL(18,2) = NULL
)
as
begin
set
nocount on;
--trả về tổng số bản ghi phù hợp
select count(*) as SobanGhi
from PurchaseOrders
where
(@SupplierID  is null or SupplierID = @SupplierID ) and
(@OrderDate is null or OrderDate = @OrderDate) and
(@TotalAmount is null or TotalAmount = @TotalAmount);

--Trả về thông tin các danh sách 
select *
from PurchaseOrders
where
(@SupplierID  is null or SupplierID = @SupplierID ) and
(@OrderDate is null or OrderDate = @OrderDate) and
(@TotalAmount is null or TotalAmount = @TotalAmount)
order by POID desc
offset (@page_index - 1) * @page_size rows
fetch next @page_size rows only;
end;


drop procedure [dbo].[sp_PurchaseOrders_create];



