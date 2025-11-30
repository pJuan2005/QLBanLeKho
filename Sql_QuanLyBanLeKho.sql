USE [QLBanLeKho]
GO

/****** Object:  Table [dbo].[AuditLogs]    Script Date: 11/26/2025 1:54:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[AuditLogs](
	[AuditID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NULL,
	[Username] [varchar](50) NULL,
	[FullName] [nvarchar](100) NULL,
	[Action] [nvarchar](200) NOT NULL,
	[EntityName] [nvarchar](100) NULL,
	[EntityID] [int] NULL,
	[Operation] [nvarchar](20) NOT NULL,
	[Details] [nvarchar](max) NULL,
	[CreatedAt] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[AuditID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[AuditLogs] ADD  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO

ALTER TABLE [dbo].[AuditLogs]  WITH CHECK ADD  CONSTRAINT [FK_AuditLogs_Users] FOREIGN KEY([UserID])
REFERENCES [dbo].[Users] ([UserID])
GO

ALTER TABLE [dbo].[AuditLogs] CHECK CONSTRAINT [FK_AuditLogs_Users]
GO


USE [QLBanLeKho]
GO

/****** Object:  Table [dbo].[Categories]    Script Date: 11/26/2025 1:54:33 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Categories](
	[CategoryID] [int] IDENTITY(1,1) NOT NULL,
	[CategoryName] [nvarchar](100) NOT NULL,
	[Description] [nvarchar](255) NULL,
	[VATRate] [decimal](5, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[CategoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


USE [QLBanLeKho]
GO

/****** Object:  Table [dbo].[Customers]    Script Date: 11/26/2025 1:55:00 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Customers](
	[CustomerID] [int] IDENTITY(1,1) NOT NULL,
	[CustomerName] [nvarchar](100) NOT NULL,
	[Phone] [varchar](20) NULL,
	[Email] [nvarchar](100) NULL,
	[Address] [nvarchar](255) NULL,
	[DebtLimit] [decimal](18, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Customers] ADD  DEFAULT ((0)) FOR [DebtLimit]
GO


USE [QLBanLeKho]
GO

/****** Object:  Table [dbo].[GoodsIssueDetails]    Script Date: 11/26/2025 1:55:13 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[GoodsIssueDetails](
	[IssueID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[ProductName] [nvarchar](100) NOT NULL,
	[Quantity] [int] NOT NULL,
	
PRIMARY KEY CLUSTERED 
(
	[IssueID] ASC,
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[GoodsIssueDetails]  WITH CHECK ADD FOREIGN KEY([IssueID])
REFERENCES [dbo].[GoodsIssues] ([IssueID])
ON DELETE CASCADE
GO



USE [QLBanLeKho]
GO

/****** Object:  Table [dbo].[GoodsIssues]    Script Date: 11/26/2025 1:55:51 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[GoodsIssues](
    [IssueID] [int] IDENTITY(1,1) NOT NULL,
    [IssueDate] [datetime] NOT NULL,
    [UserID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
    [IssueID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, 
       ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) 
       ON [PRIMARY]
) ON [PRIMARY]
GO

-- Default constraint cho IssueDate vẫn còn
ALTER TABLE [dbo].[GoodsIssues] ADD DEFAULT (getdate()) FOR [IssueDate]
GO

-- Khóa ngoại tới bảng Users vẫn còn
ALTER TABLE [dbo].[GoodsIssues] WITH CHECK ADD CONSTRAINT [FK_GoodsIssues_Users] FOREIGN KEY([UserID])
REFERENCES [dbo].[Users] ([UserID])
GO

ALTER TABLE [dbo].[GoodsIssues] CHECK CONSTRAINT [FK_GoodsIssues_Users]
GO




USE [QLBanLeKho]
GO

/****** Object:  Table [dbo].[GoodsReceiptDetails]    Script Date: 11/26/2025 1:56:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[GoodsReceiptDetails](
	[ReceiptID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[ProductName] [nvarchar](100) NOT NULL,
	[Quantity] [int] NOT NULL,
	[UnitPrice] [decimal](18, 2) NOT NULL,
	[ExpiryDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[ReceiptID] ASC,
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[GoodsReceiptDetails]  WITH CHECK ADD FOREIGN KEY([ReceiptID])
REFERENCES [dbo].[GoodsReceipts] ([ReceiptID])
ON DELETE CASCADE
GO


USE [QLBanLeKho]
GO

/****** Object:  Table [dbo].[GoodsReceipts]    Script Date: 11/26/2025 1:56:21 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[GoodsReceipts](
	[ReceiptID] [int] IDENTITY(1,1) NOT NULL,
	[POID] [int] NULL,
	[ReceiptDate] [date] NOT NULL,
	[TotalAmount] [decimal](18, 2) NULL,
	[UserID] [int] NOT NULL,
	[BatchNo] [varchar](50) NULL,
	[Status] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[ReceiptID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[GoodsReceipts] ADD  CONSTRAINT [DF_GoodsReceipts_Status]  DEFAULT ('Unpaid') FOR [Status]
GO

ALTER TABLE [dbo].[GoodsReceipts]  WITH CHECK ADD  CONSTRAINT [FK_GoodsReceipts_PurchaseOrders] FOREIGN KEY([POID])
REFERENCES [dbo].[PurchaseOrders] ([POID])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[GoodsReceipts] CHECK CONSTRAINT [FK_GoodsReceipts_PurchaseOrders]
GO


USE [QLBanLeKho]
GO

/****** Object:  Table [dbo].[Invoices]    Script Date: 11/26/2025 1:56:33 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Invoices](
	[InvoiceID] [int] IDENTITY(1,1) NOT NULL,
	[SaleID] [int] NOT NULL,
	[InvoiceNo] [varchar](50) NOT NULL,
	[InvoiceDate] [date] NOT NULL,
	[TotalAmount] [decimal](18, 2) NULL,
	[VATAmount] [decimal](18, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[InvoiceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SaleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[InvoiceNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Invoices]  WITH NOCHECK ADD FOREIGN KEY([SaleID])
REFERENCES [dbo].[Sales] ([SaleID])
GO


USE [QLBanLeKho]
GO

/****** Object:  Table [dbo].[Languages]    Script Date: 11/26/2025 1:56:48 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Languages](
	[LangCode] [varchar](5) NOT NULL,
	[LangName] [nvarchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[LangCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


USE [QLBanLeKho]
GO

/****** Object:  Table [dbo].[Payments]    Script Date: 11/26/2025 1:57:06 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Payments](
	[PaymentID] [int] IDENTITY(1,1) NOT NULL,
	[CustomerID] [int] NULL,
	[SupplierID] [int] NULL,
	[Amount] [decimal](18, 2) NOT NULL,
	[PaymentDate] [date] NOT NULL,
	[Method] [nvarchar](20) NOT NULL,
	[Description] [nvarchar](200) NULL,
	[SaleID] [int] NULL,
	[ReceiptID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[PaymentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Payments]  WITH NOCHECK ADD FOREIGN KEY([CustomerID])
REFERENCES [dbo].[Customers] ([CustomerID])
GO

ALTER TABLE [dbo].[Payments]  WITH NOCHECK ADD FOREIGN KEY([SupplierID])
REFERENCES [dbo].[Suppliers] ([SupplierID])
GO

ALTER TABLE [dbo].[Payments]  WITH CHECK ADD  CONSTRAINT [FK_Payments_ReceiptID] FOREIGN KEY([ReceiptID])
REFERENCES [dbo].[GoodsReceipts] ([ReceiptID])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Payments] CHECK CONSTRAINT [FK_Payments_ReceiptID]
GO

ALTER TABLE [dbo].[Payments]  WITH NOCHECK ADD  CONSTRAINT [FK_Payments_Sales_SaleID] FOREIGN KEY([SaleID])
REFERENCES [dbo].[Sales] ([SaleID])
GO

ALTER TABLE [dbo].[Payments] CHECK CONSTRAINT [FK_Payments_Sales_SaleID]
GO

ALTER TABLE [dbo].[Payments]  WITH NOCHECK ADD  CONSTRAINT [CK_Payments_ValidParty] CHECK  (([CustomerID] IS NULL OR [SupplierID] IS NULL))
GO

ALTER TABLE [dbo].[Payments] CHECK CONSTRAINT [CK_Payments_ValidParty]
GO


USE [QLBanLeKho]
GO

/****** Object:  Table [dbo].[Products]    Script Date: 11/26/2025 1:57:22 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Products](
	[ProductID] [int] IDENTITY(1,1) NOT NULL,
	[SKU] [varchar](50) NOT NULL,
	[Barcode] [varchar](50) NOT NULL,
	[ProductName] [nvarchar](100) NOT NULL,
	[CategoryID] [int] NOT NULL,
	[UnitPrice] [decimal](18, 2) NULL,
	[Unit] [nvarchar](20) NULL,
	[MinStock] [int] NULL,
	[Status] [nvarchar](20) NULL,
	[Image] [nvarchar](255) NULL,
	[VATRate] [decimal](5, 2) NULL,
	[Quantity] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Barcode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SKU] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Products] ADD  DEFAULT ((0)) FOR [UnitPrice]
GO

ALTER TABLE [dbo].[Products] ADD  DEFAULT ((0)) FOR [MinStock]
GO

ALTER TABLE [dbo].[Products] ADD  DEFAULT ('Active') FOR [Status]
GO

ALTER TABLE [dbo].[Products] ADD  DEFAULT ((0)) FOR [Quantity]
GO

ALTER TABLE [dbo].[Products]  WITH CHECK ADD FOREIGN KEY([CategoryID])
REFERENCES [dbo].[Categories] ([CategoryID])
GO


USE [QLBanLeKho]
GO

/****** Object:  Table [dbo].[Promotions]    Script Date: 11/26/2025 1:57:40 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Promotions](
	[PromotionID] [int] IDENTITY(1,1) NOT NULL,
	[PromotionName] [nvarchar](100) NOT NULL,
	[Type] [nvarchar](20) NOT NULL,
	[Value] [decimal](18, 2) NOT NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NOT NULL,
	[CategoryID] [int] NULL,
	[Status] [nvarchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[PromotionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Promotions] ADD  DEFAULT ('Active') FOR [Status]
GO

ALTER TABLE [dbo].[Promotions]  WITH CHECK ADD FOREIGN KEY([CategoryID])
REFERENCES [dbo].[Categories] ([CategoryID])
GO


USE [QLBanLeKho]
GO

/****** Object:  Table [dbo].[PurchaseOrderDetails]    Script Date: 11/26/2025 1:58:03 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PurchaseOrderDetails](
	[POID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[UnitPrice] [decimal](18, 2) NOT NULL,
	[NameProduct] [nvarchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[POID] ASC,
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[PurchaseOrderDetails]  WITH CHECK ADD  CONSTRAINT [FK_PurchaseOrderDetails_PurchaseOrders] FOREIGN KEY([POID])
REFERENCES [dbo].[PurchaseOrders] ([POID])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[PurchaseOrderDetails] CHECK CONSTRAINT [FK_PurchaseOrderDetails_PurchaseOrders]
GO


USE [QLBanLeKho]
GO

/****** Object:  Table [dbo].[PurchaseOrders]    Script Date: 11/26/2025 1:58:30 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PurchaseOrders](
	[POID] [int] IDENTITY(1,1) NOT NULL,
	[SupplierID] [int] NOT NULL,
	[OrderDate] [date] NOT NULL,
	[TotalAmount] [decimal](18, 2) NULL,
	[Status] [nvarchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[POID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[PurchaseOrders] ADD  DEFAULT ('Pending') FOR [Status]
GO

ALTER TABLE [dbo].[PurchaseOrders]  WITH CHECK ADD FOREIGN KEY([SupplierID])
REFERENCES [dbo].[Suppliers] ([SupplierID])
GO


USE [QLBanLeKho]
GO

/****** Object:  Table [dbo].[Returns]    Script Date: 11/26/2025 1:58:41 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Returns](
	[ReturnID] [int] IDENTITY(1,1) NOT NULL,
	[ReturnType] [tinyint] NULL,
	[SaleID] [int] NULL,
	[ReceiptID] [int] NULL,
	[CustomerID] [int] NULL,
	[SupplierID] [int] NULL,
	[PartnerName] [nvarchar](100) NULL,
	[PartnerPhone] [varchar](20) NULL,
	[ReturnDate] [datetime] NOT NULL,
	[Reason] [nvarchar](255) NULL,
	[ProductID] [int] NOT NULL,
	[ProductName] [nvarchar](100) NULL,
	[Quantity] [int] NOT NULL,
	[UnitPrice] [decimal](18, 2) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ReturnID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Returns] ADD  DEFAULT (getdate()) FOR [ReturnDate]
GO

ALTER TABLE [dbo].[Returns]  WITH CHECK ADD FOREIGN KEY([CustomerID])
REFERENCES [dbo].[Customers] ([CustomerID])
GO

ALTER TABLE [dbo].[Returns]  WITH CHECK ADD FOREIGN KEY([ProductID])
REFERENCES [dbo].[Products] ([ProductID])
GO

ALTER TABLE [dbo].[Returns]  WITH CHECK ADD FOREIGN KEY([ReceiptID])
REFERENCES [dbo].[GoodsReceipts] ([ReceiptID])
GO

ALTER TABLE [dbo].[Returns]  WITH CHECK ADD FOREIGN KEY([SaleID])
REFERENCES [dbo].[Sales] ([SaleID])
GO

ALTER TABLE [dbo].[Returns]  WITH CHECK ADD FOREIGN KEY([SupplierID])
REFERENCES [dbo].[Suppliers] ([SupplierID])
GO

ALTER TABLE [dbo].[Returns]  WITH CHECK ADD CHECK  (([Quantity]>(0)))
GO


USE [QLBanLeKho]
GO

/****** Object:  Table [dbo].[Sales]    Script Date: 11/26/2025 1:58:52 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Sales](
	[SaleID] [int] IDENTITY(1,1) NOT NULL,
	[CustomerID] [int] NULL,
	[UserID] [int] NOT NULL,
	[SaleDate] [datetime] NOT NULL,
	[TotalAmount] [decimal](18, 2) NULL,
	[VATAmount] [decimal](18, 2) NULL,
	[PaymentStatus] [nvarchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[SaleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Sales] ADD  DEFAULT ('Unpaid') FOR [PaymentStatus]
GO

ALTER TABLE [dbo].[Sales]  WITH CHECK ADD FOREIGN KEY([CustomerID])
REFERENCES [dbo].[Customers] ([CustomerID])
GO

ALTER TABLE [dbo].[Sales]  WITH CHECK ADD FOREIGN KEY([UserID])
REFERENCES [dbo].[Users] ([UserID])
GO


USE [QLBanLeKho]
GO

/****** Object:  Table [dbo].[SalesItems]    Script Date: 11/26/2025 1:59:09 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SalesItems](
	[SaleID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[ProductName] [nvarchar](100) NULL,
	[Quantity] [int] NOT NULL,
	[UnitPrice] [decimal](18, 2) NOT NULL,
	[Discount] [decimal](18, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[SaleID] ASC,
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[SalesItems] ADD  DEFAULT ((0)) FOR [Discount]
GO

ALTER TABLE [dbo].[SalesItems]  WITH NOCHECK ADD FOREIGN KEY([SaleID])
REFERENCES [dbo].[Sales] ([SaleID])
ON DELETE CASCADE
GO


USE [QLBanLeKho]
GO

/****** Object:  Table [dbo].[Settings]    Script Date: 11/26/2025 1:59:20 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Settings](
	[SettingID] [int] IDENTITY(1,1) NOT NULL,
	[VATRate] [decimal](5, 2) NOT NULL,
	[DefaultLanguage] [varchar](5) NOT NULL,
	[LastUpdated] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[SettingID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Settings] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO

ALTER TABLE [dbo].[Settings]  WITH CHECK ADD  CONSTRAINT [FK_Settings_Languages] FOREIGN KEY([DefaultLanguage])
REFERENCES [dbo].[Languages] ([LangCode])
GO

ALTER TABLE [dbo].[Settings] CHECK CONSTRAINT [FK_Settings_Languages]
GO


USE [QLBanLeKho]
GO

/****** Object:  Table [dbo].[StockCards]    Script Date: 11/26/2025 1:59:31 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[StockCards](
	[StockID] [int] IDENTITY(1,1) NOT NULL,
	[ProductID] [int] NOT NULL,
	[ProductName] [nvarchar](100) NOT NULL,
	[TransactionType] [nvarchar](10) NOT NULL,
	[Quantity] [int] NOT NULL,
	[Balance] [int] NOT NULL,
	[ReceiptID] [int] NULL,
	[IssueID] [int] NULL,
	[TransactionDate] [datetime] NOT NULL,
	[SupplierID] [int] NULL,
	[BatchNo] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[StockID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[StockCards]  WITH CHECK ADD  CONSTRAINT [FK_StockCards_GoodsIssues] FOREIGN KEY([IssueID])
REFERENCES [dbo].[GoodsIssues] ([IssueID])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[StockCards] CHECK CONSTRAINT [FK_StockCards_GoodsIssues]
GO

ALTER TABLE [dbo].[StockCards]  WITH CHECK ADD  CONSTRAINT [FK_StockCards_GoodsReceipts] FOREIGN KEY([ReceiptID])
REFERENCES [dbo].[GoodsReceipts] ([ReceiptID])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[StockCards] CHECK CONSTRAINT [FK_StockCards_GoodsReceipts]
GO

ALTER TABLE [dbo].[StockCards]  WITH CHECK ADD  CONSTRAINT [FK_StockCards_Suppliers] FOREIGN KEY([SupplierID])
REFERENCES [dbo].[Suppliers] ([SupplierID])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[StockCards] CHECK CONSTRAINT [FK_StockCards_Suppliers]
GO


USE [QLBanLeKho]
GO

/****** Object:  Table [dbo].[Suppliers]    Script Date: 11/26/2025 1:59:42 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Suppliers](
	[SupplierID] [int] IDENTITY(1,1) NOT NULL,
	[SupplierName] [nvarchar](100) NOT NULL,
	[Address] [nvarchar](255) NULL,
	[Phone] [varchar](20) NULL,
	[Email] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[SupplierID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


USE [QLBanLeKho]
GO

/****** Object:  Table [dbo].[Users]    Script Date: 11/26/2025 1:59:55 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Users](
	[UserID] [int] IDENTITY(1,1) NOT NULL,
	[Username] [varchar](50) NOT NULL,
	[PasswordHash] [varchar](255) NOT NULL,
	[Role] [nvarchar](20) NOT NULL,
	[FullName] [nvarchar](100) NULL,
	[Email] [nvarchar](100) NULL,
	[Phone] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Username] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


USE [QLBanLeKho]
GO

/****** Object:  Trigger [dbo].[trg_Categories_DefaultVAT]    Script Date: 11/26/2025 2:00:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[trg_Categories_DefaultVAT]
ON [dbo].[Categories]
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
GO

ALTER TABLE [dbo].[Categories] ENABLE TRIGGER [trg_Categories_DefaultVAT]
GO


USE [QLBanLeKho]
GO

/****** Object:  Trigger [dbo].[trg_AfterInsert_GoodsIssueDetails]    Script Date: 11/26/2025 2:00:41 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[trg_AfterInsert_GoodsIssueDetails]
ON [dbo].[GoodsIssueDetails]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Tạo bản ghi mới trong StockCards khi thêm mới phiếu xuất kho
    INSERT INTO StockCards (
        ProductID,
        ProductName,
        TransactionType,
        Quantity,
        Balance,
        ReceiptID,
        IssueID,
        TransactionDate,
        SupplierID,
        BatchNo
    )
    SELECT 
        i.ProductID,                              -- Mã sản phẩm
        i.ProductName,                            -- Tên sản phẩm
        N'OUT' AS TransactionType,                -- Loại giao dịch: xuất kho
        i.Quantity,                               -- Số lượng xuất
        i.Quantity AS Balance,                    -- Tồn sau giao dịch (ban đầu bằng số lượng xuất)
        NULL AS ReceiptID,                        -- Không liên quan đến phiếu nhập
        i.IssueID,                                -- Mã phiếu xuất kho
        gi.IssueDate AS TransactionDate,          -- Ngày xuất kho
        NULL AS SupplierID,                       -- Không có nhà cung cấp trong xuất kho
        NULL AS BatchNo                           -- Không còn thông tin số lô
    FROM inserted i
    INNER JOIN GoodsIssues gi
        ON i.IssueID = gi.IssueID;                -- Lấy ngày xuất kho
END;
GO

ALTER TABLE [dbo].[GoodsIssueDetails] ENABLE TRIGGER [trg_AfterInsert_GoodsIssueDetails]
GO


USE [QLBanLeKho]
GO

/****** Object:  Trigger [dbo].[trg_UpdateProductsQuantity_AfterDelete]    Script Date: 11/26/2025 2:00:52 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[trg_UpdateProductsQuantity_AfterDelete]
ON [dbo].[GoodsIssueDetails]
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Khi xóa chi tiết xuất kho → trừ số lượng khỏi Products.Quantity
    UPDATE p
    SET p.Quantity = p.Quantity - d.Quantity
    FROM Products p
    INNER JOIN deleted d ON p.ProductID = d.ProductID;
END;
GO

ALTER TABLE [dbo].[GoodsIssueDetails] ENABLE TRIGGER [trg_UpdateProductsQuantity_AfterDelete]
GO






USE [QLBanLeKho]
GO

/****** Object:  Trigger [dbo].[trg_AfterInsert_GoodsReceiptDetails]    Script Date: 11/26/2025 2:01:21 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--trigger tự động tạo bảng stockcard
CREATE TRIGGER [dbo].[trg_AfterInsert_GoodsReceiptDetails]
ON [dbo].[GoodsReceiptDetails]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO StockCards (
        ProductID,
        ProductName,
        TransactionType,
        Quantity,
        Balance,
        ReceiptID,
        IssueID,
        TransactionDate,
        SupplierID,
        BatchNo
    )
    SELECT 
        i.ProductID,
        i.ProductName,
        'IN',                          -- luôn là IN
        i.Quantity,
        i.Quantity,                    -- Balance = Quantity nhập
        i.ReceiptID,
        NULL,                          -- IssueID để null
        gr.ReceiptDate,                -- lấy từ GoodsReceipts
        po.SupplierID,                 -- lấy từ PurchaseOrders
        gr.BatchNo                     -- lấy từ GoodsReceipts
    FROM inserted i
    INNER JOIN GoodsReceipts gr ON i.ReceiptID = gr.ReceiptID
    INNER JOIN PurchaseOrders po ON gr.POID = po.POID;
END;
GO

ALTER TABLE [dbo].[GoodsReceiptDetails] ENABLE TRIGGER [trg_AfterInsert_GoodsReceiptDetails]
GO


USE [QLBanLeKho]
GO

/****** Object:  Trigger [dbo].[trg_DecreaseTotalAmount_AfterDelete_GoodsReceiptDetails]    Script Date: 11/26/2025 2:01:37 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[trg_DecreaseTotalAmount_AfterDelete_GoodsReceiptDetails]
ON [dbo].[GoodsReceiptDetails]
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Bảng tạm lưu các ReceiptID bị ảnh hưởng
    DECLARE @ChangedReceipts TABLE (ReceiptID INT);
    INSERT INTO @ChangedReceipts SELECT DISTINCT ReceiptID FROM deleted;

    -- Trừ đúng giá trị dòng vừa xóa khỏi TotalAmount (bao gồm VAT)
    UPDATE GR
    SET GR.TotalAmount = ISNULL(GR.TotalAmount, 0) - ISNULL(d.TotalToSubtract, 0)
    FROM GoodsReceipts GR
    INNER JOIN (
        SELECT 
            d.ReceiptID,
            SUM(d.Quantity * d.UnitPrice * (1 + ISNULL(p.VATRate, 0) / 100)) AS TotalToSubtract
        FROM deleted d
        INNER JOIN Products p ON d.ProductID = p.ProductID
        GROUP BY d.ReceiptID
    ) d ON GR.ReceiptID = d.ReceiptID;

    -- Nếu không còn dòng nào trong chi tiết phiếu nhập → đưa TotalAmount về 0
    UPDATE GR
    SET GR.TotalAmount = 0
    FROM GoodsReceipts GR
    WHERE NOT EXISTS (
        SELECT 1 FROM GoodsReceiptDetails grd WHERE grd.ReceiptID = GR.ReceiptID
    )
    AND EXISTS (
        SELECT 1 FROM @ChangedReceipts cr WHERE cr.ReceiptID = GR.ReceiptID
    );
END;
GO

ALTER TABLE [dbo].[GoodsReceiptDetails] ENABLE TRIGGER [trg_DecreaseTotalAmount_AfterDelete_GoodsReceiptDetails]
GO


USE [QLBanLeKho]
GO

/****** Object:  Trigger [dbo].[trg_UpdateTotalAmount_AfterInsert_GoodsReceiptDetails]    Script Date: 11/26/2025 2:01:49 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[trg_UpdateTotalAmount_AfterInsert_GoodsReceiptDetails]
ON [dbo].[GoodsReceiptDetails]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ChangedReceipts TABLE (ReceiptID INT);
    INSERT INTO @ChangedReceipts SELECT DISTINCT ReceiptID FROM inserted;

    -- Cập nhật lại TotalAmount có VAT
    UPDATE GR
    SET GR.TotalAmount = ISNULL(T.TotalAmount, 0)
    FROM GoodsReceipts GR
    INNER JOIN @ChangedReceipts R ON GR.ReceiptID = R.ReceiptID
    LEFT JOIN (
        SELECT 
            GRD.ReceiptID, 
            SUM(GRD.Quantity * GRD.UnitPrice * (1 + ISNULL(P.VATRate, 0) / 100)) AS TotalAmount
        FROM GoodsReceiptDetails GRD
        LEFT JOIN Products P ON GRD.ProductID = P.ProductID
        GROUP BY GRD.ReceiptID
    ) T ON GR.ReceiptID = T.ReceiptID;
END;
GO

ALTER TABLE [dbo].[GoodsReceiptDetails] ENABLE TRIGGER [trg_UpdateTotalAmount_AfterInsert_GoodsReceiptDetails]
GO


USE [QLBanLeKho]
GO

/****** Object:  Trigger [dbo].[trg_AfterInsert_Payments]    Script Date: 11/26/2025 2:02:18 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--trigger tự động nhập supplierID qua receiptID
CREATE TRIGGER [dbo].[trg_AfterInsert_Payments]
ON [dbo].[Payments]
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

ALTER TABLE [dbo].[Payments] ENABLE TRIGGER [trg_AfterInsert_Payments]
GO


USE [QLBanLeKho]
GO

/****** Object:  Trigger [dbo].[trg_UpdateGoodsReceiptsStatus]    Script Date: 11/26/2025 2:02:30 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--trigger cập nhật status
CREATE TRIGGER [dbo].[trg_UpdateGoodsReceiptsStatus]
ON [dbo].[Payments]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH PaySum AS (
        SELECT 
            i.ReceiptID,
            SUM(p.Amount) AS TotalPaid
        FROM inserted i
        JOIN Payments p ON p.ReceiptID = i.ReceiptID
        WHERE i.ReceiptID IS NOT NULL
        GROUP BY i.ReceiptID
    )
    UPDATE gr
    SET 
        gr.Status = 
            CASE 
                WHEN ps.TotalPaid < gr.TotalAmount THEN 'partial'
                WHEN ps.TotalPaid = gr.TotalAmount THEN 'paid'
            END
    FROM GoodsReceipts gr
    JOIN PaySum ps ON gr.ReceiptID = ps.ReceiptID;
END;

GO

ALTER TABLE [dbo].[Payments] ENABLE TRIGGER [trg_UpdateGoodsReceiptsStatus]
GO


USE [QLBanLeKho]
GO

/****** Object:  Trigger [dbo].[trg_UpdatePaymentStatus]    Script Date: 11/26/2025 2:02:42 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[trg_UpdatePaymentStatus]
ON [dbo].[Payments]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Những SaleID bị ảnh hưởng bởi batch INSERT/UPDATE/DELETE lần này
    ;WITH ChangedSales AS (
        SELECT DISTINCT SaleID
        FROM inserted
        WHERE SaleID IS NOT NULL
        
        UNION
        
        SELECT DISTINCT SaleID
        FROM deleted
        WHERE SaleID IS NOT NULL
    ),

    PaidAgg AS (
        SELECT 
            s.SaleID,
            s.TotalAmount,
            SUM(ISNULL(p.Amount,0)) AS TotalPaid
        FROM Sales s
        LEFT JOIN Payments p
               ON p.SaleID = s.SaleID
              AND p.CustomerID IS NOT NULL   -- chỉ tiền KH trả
        WHERE s.SaleID IN (SELECT SaleID FROM ChangedSales)
        GROUP BY s.SaleID, s.TotalAmount
    )
    UPDATE s
    SET PaymentStatus =
        CASE 
            WHEN ISNULL(pa.TotalPaid,0) >= ISNULL(pa.TotalAmount,0) THEN 'Paid'
            WHEN ISNULL(pa.TotalPaid,0) = 0 THEN 'Unpaid'
            ELSE 'Partial'
        END
    FROM Sales s
    JOIN PaidAgg pa ON pa.SaleID = s.SaleID;
END;
GO

ALTER TABLE [dbo].[Payments] ENABLE TRIGGER [trg_UpdatePaymentStatus]
GO


USE [QLBanLeKho]
GO

/****** Object:  Trigger [dbo].[trg_SetVATRate_FromCategory]    Script Date: 11/26/2025 2:02:57 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[trg_SetVATRate_FromCategory]
ON [dbo].[Products]
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Cập nhật VATRate cho các dòng mới thêm hoặc cập nhật mà VATRate = NULL
    UPDATE p
    SET p.VATRate = c.VATRate
    FROM Products p
    INNER JOIN inserted i ON p.ProductID = i.ProductID
    INNER JOIN Categories c ON p.CategoryID = c.CategoryID
    WHERE i.VATRate IS NULL;
END;

GO

ALTER TABLE [dbo].[Products] ENABLE TRIGGER [trg_SetVATRate_FromCategory]
GO


USE [QLBanLeKho]
GO

/****** Object:  Trigger [dbo].[trg_DecreaseTotalAmount_AfterDelete]    Script Date: 11/26/2025 2:03:16 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[trg_DecreaseTotalAmount_AfterDelete]
ON [dbo].[PurchaseOrderDetails]
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Bảng tạm lưu các POID bị ảnh hưởng
    DECLARE @ChangedPOIDs TABLE (POID INT);
    INSERT INTO @ChangedPOIDs SELECT DISTINCT POID FROM deleted;

    -- Trừ đúng giá trị dòng vừa xóa khỏi TotalAmount (có VAT)
    UPDATE PO
    SET PO.TotalAmount = ISNULL(PO.TotalAmount, 0) - ISNULL(d.TotalToSubtract, 0)
    FROM PurchaseOrders PO
    INNER JOIN (
        SELECT 
            d.POID,
            SUM(d.Quantity * d.UnitPrice * (1 + ISNULL(p.VATRate, 0) / 100)) AS TotalToSubtract
        FROM deleted d
        INNER JOIN Products p ON d.ProductID = p.ProductID
        GROUP BY d.POID
    ) d ON PO.POID = d.POID;

    -- Nếu không còn dòng nào trong chi tiết đơn mua → đưa TotalAmount về 0
    UPDATE PO
    SET PO.TotalAmount = 0
    FROM PurchaseOrders PO
    WHERE NOT EXISTS (
        SELECT 1 FROM PurchaseOrderDetails pd WHERE pd.POID = PO.POID
    )
    AND EXISTS (
        SELECT 1 FROM @ChangedPOIDs cs WHERE cs.POID = PO.POID
    );
END;
GO

ALTER TABLE [dbo].[PurchaseOrderDetails] ENABLE TRIGGER [trg_DecreaseTotalAmount_AfterDelete]
GO


USE [QLBanLeKho]
GO

/****** Object:  Trigger [dbo].[trg_UpdateTotalAmount_AfterInsert]    Script Date: 11/26/2025 2:03:29 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[trg_UpdateTotalAmount_AfterInsert]
ON [dbo].[PurchaseOrderDetails]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Bảng tạm lưu các POID bị ảnh hưởng
    DECLARE @ChangedPOIDs TABLE (POID INT);
    INSERT INTO @ChangedPOIDs SELECT DISTINCT POID FROM inserted;

    -- Cập nhật lại TotalAmount cho từng POID
    UPDATE PO
    SET PO.TotalAmount = ISNULL(t.TotalAmount, 0)
    FROM PurchaseOrders PO
    INNER JOIN @ChangedPOIDs i ON PO.POID = i.POID
    INNER JOIN (
        SELECT 
            pd.POID,
            SUM(pd.Quantity * pd.UnitPrice * (1 + ISNULL(p.VATRate, 0) / 100)) AS TotalAmount
        FROM PurchaseOrderDetails pd
        INNER JOIN Products p ON pd.ProductID = p.ProductID
        WHERE pd.POID IN (SELECT POID FROM @ChangedPOIDs)
        GROUP BY pd.POID
    ) t ON PO.POID = t.POID;
END;
GO

ALTER TABLE [dbo].[PurchaseOrderDetails] ENABLE TRIGGER [trg_UpdateTotalAmount_AfterInsert]
GO


USE [QLBanLeKho]
GO

/****** Object:  Trigger [dbo].[trg_AfterInsertSales]    Script Date: 11/26/2025 2:03:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[trg_AfterInsertSales]
ON [dbo].[Sales]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Invoices (SaleID, InvoiceNo, InvoiceDate, TotalAmount, VATAmount)
    SELECT 
        i.SaleID,
        'INV' + CAST(i.SaleID AS VARCHAR(10)) + '_' + FORMAT(GETDATE(), 'yyyyMMdd'), -- Ví dụ: INV123_20251026
        i.SaleDate,
        0, -- TotalAmount mặc định
        0  -- VATAmount mặc định
    FROM inserted i;
END;
GO

ALTER TABLE [dbo].[Sales] ENABLE TRIGGER [trg_AfterInsertSales]
GO


USE [QLBanLeKho]
GO

/****** Object:  Trigger [dbo].[trg_AutoUpdateDebtLimit]    Script Date: 11/26/2025 2:04:03 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[trg_AutoUpdateDebtLimit]
ON [dbo].[Sales]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Nếu đơn hàng mới có tổng tiền > 10 triệu → gán DebtLimit = 3 triệu
    UPDATE c
    SET c.DebtLimit = 3000000
    FROM Customers c
    INNER JOIN inserted i ON i.CustomerID = c.CustomerID
    WHERE i.TotalAmount > 10000000;
END;
GO

ALTER TABLE [dbo].[Sales] ENABLE TRIGGER [trg_AutoUpdateDebtLimit]
GO


USE [QLBanLeKho]
GO

/****** Object:  Trigger [dbo].[trg_UpdateDebtLimit_WhenBigPurchase]    Script Date: 11/26/2025 2:04:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[trg_UpdateDebtLimit_WhenBigPurchase]
ON [dbo].[Sales]
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH CustTotals AS (
        SELECT  s.CustomerID,
                SUM(s.TotalAmount) AS TotalAmount
        FROM    Sales s
        INNER JOIN inserted i ON i.CustomerID = s.CustomerID
        GROUP BY s.CustomerID
    )
    UPDATE c
    SET c.DebtLimit = 3000000
    FROM Customers c
    INNER JOIN CustTotals t ON c.CustomerID = t.CustomerID
    WHERE t.TotalAmount >= 10000000      -- tổng mua ≥ 10 triệu
      AND (c.DebtLimit IS NULL OR c.DebtLimit < 3000000); -- chỉ tăng chứ không hạ
END;
GO

ALTER TABLE [dbo].[Sales] ENABLE TRIGGER [trg_UpdateDebtLimit_WhenBigPurchase]
GO


USE [QLBanLeKho]
GO

/****** Object:  Trigger [dbo].[trg_AutoUpdateSalesItemPriceDiscount]    Script Date: 11/26/2025 2:04:25 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[trg_AutoUpdateSalesItemPriceDiscount]
ON [dbo].[SalesItems]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE si
    SET 
        si.Discount = ISNULL(pr.Value, 0)
    FROM SalesItems si
    INNER JOIN inserted i ON si.SaleID = i.SaleID AND si.ProductID = i.ProductID
    INNER JOIN Products p ON i.ProductID = p.ProductID
    LEFT JOIN Promotions pr ON p.CategoryID = pr.CategoryID
        AND CAST(GETDATE() AS DATE) BETWEEN pr.StartDate AND pr.EndDate;
END;
GO

ALTER TABLE [dbo].[SalesItems] ENABLE TRIGGER [trg_AutoUpdateSalesItemPriceDiscount]
GO


USE [QLBanLeKho]
GO

/****** Object:  Trigger [dbo].[trg_DecreaseSalesTotalAfterDelete]    Script Date: 11/26/2025 2:04:37 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[trg_DecreaseSalesTotalAfterDelete]
ON [dbo].[SalesItems]
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Bảng tạm lưu các SaleID bị ảnh hưởng
    DECLARE @ChangedSales TABLE (SaleID INT);
    INSERT INTO @ChangedSales SELECT DISTINCT SaleID FROM deleted;

    -- Trừ giá trị dòng bị xóa khỏi TotalAmount và VATAmount
    UPDATE s
    SET 
        s.TotalAmount = ISNULL(s.TotalAmount, 0) - ISNULL(
            d.TotalAmountToSubtract, 0
        ),
        s.VATAmount = ISNULL(s.VATAmount, 0) - ISNULL(d.TotalVATToSubtract, 0)
    FROM Sales s
    INNER JOIN (
        SELECT 
            d.SaleID,
            SUM(d.Quantity * d.UnitPrice * (1 - d.Discount / 100) * (1 + p.VATRate / 100)) AS TotalAmountToSubtract,
            SUM(p.VATRate) AS TotalVATToSubtract
        FROM deleted d
        INNER JOIN Products p ON d.ProductID = p.ProductID
        GROUP BY d.SaleID
    ) d ON s.SaleID = d.SaleID;

    -- Nếu không còn dòng nào trong SalesItems → đưa về 0
    UPDATE s
    SET 
        s.TotalAmount = 0,
        s.VATAmount = 0
    FROM Sales s
    WHERE NOT EXISTS (
        SELECT 1 FROM SalesItems si WHERE si.SaleID = s.SaleID
    )
    AND EXISTS (
        SELECT 1 FROM @ChangedSales cs WHERE cs.SaleID = s.SaleID
    );
END;
GO

ALTER TABLE [dbo].[SalesItems] ENABLE TRIGGER [trg_DecreaseSalesTotalAfterDelete]
GO


USE [QLBanLeKho]
GO

/****** Object:  Trigger [dbo].[trg_UpdateProductQuantity_AfterSale]    Script Date: 11/26/2025 2:04:49 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[trg_UpdateProductQuantity_AfterSale]
ON [dbo].[SalesItems]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ProductID INT, @SoldQty INT, @CurrentQty INT, @NewQty INT;

    -- Duyệt qua từng ProductID được bán trong lần thêm mới
    DECLARE cur CURSOR FOR
    SELECT ProductID, Quantity
    FROM inserted;

    OPEN cur;
    FETCH NEXT FROM cur INTO @ProductID, @SoldQty;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Lấy số lượng hiện tại trong bảng Products
        SELECT @CurrentQty = Quantity
        FROM Products
        WHERE ProductID = @ProductID;

        SET @CurrentQty = ISNULL(@CurrentQty, 0);

        -- Trừ đi số lượng bán ra
        SET @NewQty = @CurrentQty - @SoldQty;

        -- Không để tồn âm
        IF @NewQty < 0
            SET @NewQty = 0;

        -- Cập nhật lại bảng Products
        UPDATE Products
        SET Quantity = @NewQty
        WHERE ProductID = @ProductID;

        FETCH NEXT FROM cur INTO @ProductID, @SoldQty;
    END;

    CLOSE cur;
    DEALLOCATE cur;
END;
GO

ALTER TABLE [dbo].[SalesItems] ENABLE TRIGGER [trg_UpdateProductQuantity_AfterSale]
GO


USE [QLBanLeKho]
GO

/****** Object:  Trigger [dbo].[trg_UpdateSalesTotal]    Script Date: 11/26/2025 2:05:00 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[trg_UpdateSalesTotal]
ON [dbo].[SalesItems]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Bảng tạm lưu các SaleID bị ảnh hưởng
    DECLARE @ChangedSales TABLE (SaleID INT);

    -- Lưu danh sách SaleID bị ảnh hưởng từ inserted / deleted
    INSERT INTO @ChangedSales(SaleID)
    SELECT DISTINCT SaleID FROM inserted
    UNION
    SELECT DISTINCT SaleID FROM deleted;

    -- Bảng tạm lưu kết quả tính toán TotalAmount và VATAmount (tiền)
    DECLARE @CalculatedTotals TABLE (
        SaleID INT,
        TotalAmount DECIMAL(18,2),
        TotalVAT    DECIMAL(18,2)
    );

    -- Tính lại Subtotal + VAT
    INSERT INTO @CalculatedTotals (SaleID, TotalAmount, TotalVAT)
    SELECT 
        si.SaleID,
        SUM( baseLine * (1 + p.VATRate / 100.0) )         AS TotalAmount,
        SUM( baseLine * (p.VATRate / 100.0) )             AS TotalVAT
    FROM SalesItems si
    JOIN Products p ON si.ProductID = p.ProductID
    CROSS APPLY (
        SELECT 
            si.Quantity * si.UnitPrice * (1 - si.Discount / 100.0) AS baseLine
    ) AS x
    WHERE si.SaleID IN (SELECT SaleID FROM @ChangedSales)
    GROUP BY si.SaleID;

    -- Cập nhật bảng Sales
    UPDATE s
    SET 
        s.TotalAmount = ISNULL(ct.TotalAmount, 0),
        s.VATAmount   = ISNULL(ct.TotalVAT, 0)
    FROM Sales s
    JOIN @ChangedSales cs   ON s.SaleID = cs.SaleID
    LEFT JOIN @CalculatedTotals ct ON s.SaleID = ct.SaleID;

    -- Cập nhật bảng Invoices (nếu có)
    UPDATE i
    SET 
        i.TotalAmount = ISNULL(ct.TotalAmount, 0),
        i.VATAmount   = ISNULL(ct.TotalVAT, 0)
    FROM Invoices i
    JOIN @ChangedSales cs   ON i.SaleID = cs.SaleID
    LEFT JOIN @CalculatedTotals ct ON i.SaleID = ct.SaleID;
END;
GO

ALTER TABLE [dbo].[SalesItems] ENABLE TRIGGER [trg_UpdateSalesTotal]
GO


USE [QLBanLeKho]
GO

/****** Object:  Trigger [dbo].[trg_UpdateBalance_AfterOut]    Script Date: 11/26/2025 2:05:17 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create TRIGGER [dbo].[trg_UpdateBalance_AfterOut]
ON [dbo].[StockCards]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    /* 1) Tổng số lượng OUT vừa chèn theo ProductID */
    WITH ins_out AS (
        SELECT ProductID, SUM(CAST(Quantity AS INT)) AS OutQty
        FROM inserted
        WHERE TransactionType = 'OUT' OR TransactionType = N'OUT'
        GROUP BY ProductID
    ),
    /* 2) Lấy Balance cũ từ bản ghi IN gần nhất của ProductID */
    old_bal AS (
        SELECT io.ProductID,
               ISNULL((
                    SELECT TOP 1 s.Balance
                    FROM StockCards s
                    WHERE s.ProductID = io.ProductID
                      AND s.TransactionType = 'IN'
                    ORDER BY s.StockID DESC
               ), 0) AS OldBalance,
               io.OutQty
        FROM ins_out io
    ),
    /* 3) Balance mới = Balance cũ - tổng OUT mới (có thể chặn âm) */
    new_bal AS (
        SELECT ProductID,
               CASE 
                   WHEN OldBalance - OutQty < 0 THEN 0
                   ELSE OldBalance - OutQty
               END AS NewBalance
        FROM old_bal
    )
    /* 4) Cập nhật Balance cho toàn bộ dòng của ProductID */
    UPDATE sc
    SET sc.Balance = nb.NewBalance
    FROM StockCards sc
    JOIN new_bal nb
      ON nb.ProductID = sc.ProductID;
END;
GO

ALTER TABLE [dbo].[StockCards] ENABLE TRIGGER [trg_UpdateBalance_AfterOut]
GO


USE [QLBanLeKho]
GO

/****** Object:  Trigger [dbo].[trg_UpdateBalance_StockCards]    Script Date: 11/26/2025 2:05:28 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create TRIGGER [dbo].[trg_UpdateBalance_StockCards]
ON [dbo].[StockCards]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    

    -- Bước 1: Tính tồn kho hiện tại cho từng ProductID bị ảnh hưởng
    DECLARE @CurrentStock TABLE (ProductID INT PRIMARY KEY, TotalBalance INT);

    INSERT INTO @CurrentStock (ProductID, TotalBalance)
    SELECT 
        ProductID,
        SUM(Quantity) AS TotalBalance
    FROM StockCards
    WHERE ProductID IN (SELECT DISTINCT ProductID FROM inserted WHERE TransactionType = 'IN')
      AND TransactionType = 'IN'
    GROUP BY ProductID;

    -- Bước 2: Cập nhật TẤT CẢ bản ghi IN của các ProductID này → Balance = TotalBalance
    UPDATE sc
    SET Balance = cs.TotalBalance
    FROM StockCards sc
    INNER JOIN @CurrentStock cs ON sc.ProductID = cs.ProductID
    
END;
GO

ALTER TABLE [dbo].[StockCards] ENABLE TRIGGER [trg_UpdateBalance_StockCards]
GO


USE [QLBanLeKho]
GO

/****** Object:  Trigger [dbo].[trg_UpdateProductQuantity_AfterOut]    Script Date: 11/26/2025 2:05:37 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[trg_UpdateProductQuantity_AfterOut]
ON [dbo].[StockCards]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ProductID INT, @OutQty INT, @CurrentQty INT, @NewQty INT;

    -- Duyệt qua từng ProductID trong các bản ghi mới có TransactionType = 'OUT'
    DECLARE cur CURSOR FOR
    SELECT ProductID, Quantity
    FROM inserted
    WHERE TransactionType = 'OUT';

    OPEN cur;
    FETCH NEXT FROM cur INTO @ProductID, @OutQty;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Lấy số lượng hiện tại ở quầy (bảng Products)
        SELECT @CurrentQty = Quantity
        FROM Products
        WHERE ProductID = @ProductID;

        SET @CurrentQty = ISNULL(@CurrentQty, 0);

        -- Cộng thêm số lượng vừa xuất kho
        SET @NewQty = @CurrentQty + @OutQty;

        -- Cập nhật lại Products.Quantity
        UPDATE Products
        SET Quantity = @NewQty
        WHERE ProductID = @ProductID;

        FETCH NEXT FROM cur INTO @ProductID, @OutQty;
    END;

    CLOSE cur;
    DEALLOCATE cur;
END;
GO

ALTER TABLE [dbo].[StockCards] ENABLE TRIGGER [trg_UpdateProductQuantity_AfterOut]
GO


USE [QLBanLeKho]
GO

/****** Object:  Trigger [dbo].[trg_UpdateQuantity_AfterOut]    Script Date: 11/26/2025 2:05:47 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[trg_UpdateQuantity_AfterOut]
ON [dbo].[StockCards]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ProductID INT, @QtyToIssue INT, @StockID INT, @QtyInLot INT;

    -- Duyệt qua từng ProductID có bản ghi OUT mới
    DECLARE cur CURSOR FOR
    SELECT ProductID, SUM(Quantity) AS TotalOutQty
    FROM inserted
    WHERE TransactionType = 'OUT'
    GROUP BY ProductID;

    OPEN cur;
    FETCH NEXT FROM cur INTO @ProductID, @QtyToIssue;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- FIFO: Trừ dần quantity của các bản ghi “IN”
        DECLARE curLot CURSOR FOR
        SELECT StockID, Quantity
        FROM StockCards
        WHERE ProductID = @ProductID
          AND TransactionType = 'IN'
          AND Quantity > 0
        ORDER BY StockID ASC;

        OPEN curLot;
        FETCH NEXT FROM curLot INTO @StockID, @QtyInLot;

        WHILE @@FETCH_STATUS = 0 AND @QtyToIssue > 0
        BEGIN
            IF @QtyInLot <= @QtyToIssue
            BEGIN
                UPDATE StockCards
                SET Quantity = 0
                WHERE StockID = @StockID;

                SET @QtyToIssue = @QtyToIssue - @QtyInLot;
            END
            ELSE
            BEGIN
                UPDATE StockCards
                SET Quantity = Quantity - @QtyToIssue
                WHERE StockID = @StockID;

                SET @QtyToIssue = 0;
            END;

            FETCH NEXT FROM curLot INTO @StockID, @QtyInLot;
        END

        CLOSE curLot;
        DEALLOCATE curLot;

        FETCH NEXT FROM cur INTO @ProductID, @QtyToIssue;
    END;

    CLOSE cur;
    DEALLOCATE cur;
END;
GO

ALTER TABLE [dbo].[StockCards] ENABLE TRIGGER [trg_UpdateQuantity_AfterOut]
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_ap_open_bills]    Script Date: 11/26/2025 2:06:06 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_ap_open_bills]
(
    @page_index INT = 1,
    @page_size  INT = 10,
    @search     NVARCHAR(200) = N'',
    @from_date  DATE = NULL,
    @to_date    DATE = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH Bills AS (
        SELECT 
            r.ReceiptID,
            r.ReceiptDate,
            po.SupplierID,       -- 🔹 Lấy SupplierID từ PurchaseOrders
            s.SupplierName,
            r.TotalAmount,

            PaidAmount = ISNULL((
                SELECT SUM(p.Amount)
                FROM Payments p
                WHERE p.ReceiptID = r.ReceiptID
            ), 0),

            Remaining = r.TotalAmount -
                ISNULL((
                    SELECT SUM(p.Amount)
                    FROM Payments p
                    WHERE p.ReceiptID = r.ReceiptID
                ), 0)
        FROM GoodsReceipts r
        LEFT JOIN PurchaseOrders po ON po.POID = r.POID          -- 🔹 JOIN qua PO
        LEFT JOIN Suppliers s ON s.SupplierID = po.SupplierID     -- 🔹 JOIN supplier
        WHERE
            (@search = N''
                OR s.SupplierName LIKE N'%'+@search+N'%'
                OR CAST(r.ReceiptID AS NVARCHAR(20)) LIKE N'%'+@search+N'%'
            )
            AND (@from_date IS NULL OR r.ReceiptDate >= @from_date)
            AND (@to_date   IS NULL OR r.ReceiptDate < DATEADD(DAY, 1, @to_date))
    )

    SELECT 
        CAST(COUNT(*) OVER() AS BIGINT) AS TotalItems,
        ReceiptID,
        ReceiptDate,
        SupplierID,
        SupplierName,
        TotalAmount,
        PaidAmount,
        Remaining
    FROM Bills
    WHERE Remaining > 0
    ORDER BY ReceiptDate DESC, ReceiptID DESC
    OFFSET (@page_index - 1) * @page_size ROWS
    FETCH NEXT @page_size ROWS ONLY;
END;
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_ap_supplier_getdatabyid]    Script Date: 11/26/2025 2:06:18 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_ap_supplier_getdatabyid]
    @SupplierID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @SupplierName NVARCHAR(100),
        @ReceivedTotal DECIMAL(18,2),
        @PaymentsTotal DECIMAL(18,2);

    -- Tên NCC
    SELECT @SupplierName = s.SupplierName
    FROM dbo.Suppliers s
    WHERE s.SupplierID = @SupplierID;

    -- Nếu không tồn tại NCC, trả về rỗng
    IF (@SupplierName IS NULL)
    BEGIN
        SELECT 
            CAST(NULL AS INT)            AS SupplierID,
            CAST(NULL AS NVARCHAR(100))  AS SupplierName,
            CAST(0.00 AS DECIMAL(18,2))  AS ReceivedTotal,
            CAST(0.00 AS DECIMAL(18,2))  AS PaymentsTotal,
            CAST(0.00 AS DECIMAL(18,2))  AS CurrentPayable;
        RETURN;
    END

    -- Tổng phát sinh phải trả (theo GoodsReceipts của NCC)
    SELECT @ReceivedTotal = ISNULL(SUM(gr.TotalAmount),0.00)
    FROM dbo.GoodsReceipts gr
    INNER JOIN dbo.PurchaseOrders po ON po.POID = gr.POID
    WHERE po.SupplierID = @SupplierID;

    -- Tổng thanh toán đã trả cho NCC
    SELECT @PaymentsTotal = ISNULL(SUM(p.Amount),0.00)
    FROM dbo.Payments p
    WHERE p.SupplierID = @SupplierID;

    -- Kết quả
    SELECT 
        @SupplierID                  AS SupplierID,
        @SupplierName                AS SupplierName,
        @ReceivedTotal               AS ReceivedTotal,
        @PaymentsTotal               AS PaymentsTotal,
        (@ReceivedTotal-@PaymentsTotal) AS CurrentPayable;
END
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_ap_supplier_search]    Script Date: 11/26/2025 2:06:31 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_ap_supplier_search]
    @page_index INT,
    @page_size  INT,
    @search     NVARCHAR(200) = N''   -- từ khóa tìm kiếm (rỗng = lấy tất cả)
AS
BEGIN
    SET NOCOUNT ON;

    -- Nếu search là số thì dùng để so khớp ID
    DECLARE @searchId INT = TRY_CONVERT(INT, NULLIF(@search, N''));

    ;WITH GRNBySupp AS (
        SELECT po.SupplierID, SUM(ISNULL(gr.TotalAmount, 0)) AS TotalReceived
        FROM dbo.GoodsReceipts gr
        INNER JOIN dbo.PurchaseOrders po ON po.POID = gr.POID
        GROUP BY po.SupplierID
    ),
    PayBySupp AS (
        SELECT p.SupplierID, SUM(ISNULL(p.Amount, 0)) AS Paid
        FROM dbo.Payments p
        WHERE p.SupplierID IS NOT NULL
        GROUP BY p.SupplierID
    ),
    Src AS (
        SELECT 
            s.SupplierID,
            s.SupplierName,
            ISNULL(g.TotalReceived, 0) AS TotalReceived,
            ISNULL(p.Paid, 0)          AS Paid,
            ISNULL(g.TotalReceived, 0) - ISNULL(p.Paid, 0) AS AP_Balance
        FROM dbo.Suppliers s
        LEFT JOIN GRNBySupp g ON g.SupplierID = s.SupplierID
        LEFT JOIN PayBySupp p ON p.SupplierID = s.SupplierID
        WHERE
            (
                @search = N''   -- không nhập gì -> lấy tất cả
                OR (@searchId IS NOT NULL AND s.SupplierID = @searchId) -- tìm theo ID
                OR (@searchId IS NULL AND ( -- tìm theo text
                       s.SupplierName       LIKE N'%'+@search+N'%'
                    OR ISNULL(s.Email,'')   LIKE N'%'+@search+N'%'
                    OR ISNULL(s.Address,'') LIKE N'%'+@search+N'%'
                ))
            )
    )
    SELECT 
        CAST(COUNT(1) OVER() AS BIGINT) AS RecordCount,
        SupplierID,
        SupplierName,
        TotalReceived,
        Paid,
        AP_Balance AS CurrentPayable
    FROM Src
    ORDER BY
        CurrentPayable DESC,
        SupplierName ASC
    OFFSET (@page_index - 1) * @page_size ROWS
    FETCH NEXT @page_size ROWS ONLY;
END
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_ar_customer_detail]    Script Date: 11/26/2025 2:06:41 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_ar_customer_detail]
    @CustomerID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        c.CustomerID,
        c.CustomerName,
        c.DebtLimit,
        SalesTotal = ISNULL((
            SELECT SUM(ISNULL(s.TotalAmount,0))
            FROM Sales s
            WHERE s.CustomerID = c.CustomerID
              AND ISNULL(s.PaymentStatus,'Unpaid') IN ('Unpaid','Partial','Paid')
        ),0),
        PaymentsTotal = ISNULL((
            SELECT SUM(ISNULL(p.Amount,0))
            FROM Payments p
            WHERE p.CustomerID = c.CustomerID
              AND p.SupplierID IS NULL  -- chỉ thanh toán của KH
        ),0)
    INTO #tmp
    FROM Customers c
    WHERE c.CustomerID = @CustomerID;

    SELECT 
        t.CustomerID, 
        t.CustomerName, 
        t.DebtLimit,
        t.SalesTotal, 
        t.PaymentsTotal,
        CurrentDebt = t.SalesTotal - t.PaymentsTotal
    FROM #tmp t;
END
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_ar_customer_search]    Script Date: 11/26/2025 2:06:53 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_ar_customer_search]
  @page_index INT,
  @page_size  INT,
  @search     NVARCHAR(200) = N''
AS
BEGIN
  SET NOCOUNT ON;

  ;WITH Debt AS (
    SELECT 
      c.CustomerID,
      c.CustomerName,
      c.Phone,               -- << THÊM
      c.DebtLimit,
      SalesTotal = ISNULL((
        SELECT SUM(ISNULL(s.TotalAmount,0))
        FROM Sales s
        WHERE s.CustomerID = c.CustomerID
          AND ISNULL(s.PaymentStatus,'Unpaid') IN ('Unpaid','Partial','Paid')
      ),0),
      PaymentsTotal = ISNULL((
        SELECT SUM(ISNULL(p.Amount,0))
        FROM Payments p
        WHERE p.CustomerID = c.CustomerID
          AND p.SupplierID IS NULL
      ),0)
    FROM Customers c
    WHERE (@search = N''
       OR c.CustomerName LIKE N'%' + @search + N'%'
       OR ISNULL(c.Phone,'')  LIKE N'%' + @search + N'%'
       OR ISNULL(c.Email,'')  LIKE N'%' + @search + N'%'
       OR ISNULL(c.Address,'')LIKE N'%' + @search + N'%')
  )
  SELECT
    d.CustomerID,
    d.CustomerName,
    d.Phone,                 -- << THÊM
    d.DebtLimit,
    CurrentDebt = CASE 
                    WHEN (d.SalesTotal - d.PaymentsTotal) < 0 THEN 0
                    ELSE (d.SalesTotal - d.PaymentsTotal)
                  END,
    IsOverLimit = CAST(CASE 
                         WHEN (d.SalesTotal - d.PaymentsTotal) > d.DebtLimit THEN 1 ELSE 0
                       END AS bit),
    RecordCount = COUNT(*) OVER()
  FROM Debt d
  ORDER BY d.CustomerName
  OFFSET (@page_index - 1) * @page_size ROWS 
  FETCH NEXT @page_size ROWS ONLY;
END
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_ar_get_current_debt]    Script Date: 11/26/2025 2:07:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_ar_get_current_debt]
    @CustomerID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
      ISNULL((
        SELECT SUM(ISNULL(s.TotalAmount,0))
        FROM Sales s
        WHERE s.CustomerID = @CustomerID
          AND ISNULL(s.PaymentStatus,'Unpaid') IN ('Unpaid','Partial','Paid')
      ),0)
      -
      ISNULL((
        SELECT SUM(ISNULL(p.Amount,0))
        FROM Payments p
        WHERE p.CustomerID = @CustomerID
          AND p.SupplierID IS NULL
      ),0) AS CurrentDebt;
END
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_ar_get_debt_limit]    Script Date: 11/26/2025 2:07:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_ar_get_debt_limit]
    @CustomerID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ISNULL(DebtLimit,0) AS DebtLimit
    FROM Customers
    WHERE CustomerID = @CustomerID;
END
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_ar_open_invoices]    Script Date: 11/28/2025 2:24:59 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_ar_open_invoices]
(
    @page_index INT = 1,
    @page_size  INT = 10,
    @search     NVARCHAR(200) = N'',
    @from_date  DATE = NULL,
    @to_date    DATE = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH Invoice AS (
        SELECT 
            s.SaleID,
            -- ưu tiên ngày hóa đơn, nếu chưa có thì lấy SaleDate
            SaleDate     = ISNULL(i.InvoiceDate, s.SaleDate),
            s.CustomerID,
            c.CustomerName,
            c.Phone,
            s.TotalAmount,

            PaidAmount = ISNULL((
                SELECT SUM(p.Amount)
                FROM Payments p
                WHERE p.SaleID = s.SaleID
            ), 0),

            Remaining = s.TotalAmount -
                ISNULL((
                    SELECT SUM(p.Amount)
                    FROM Payments p
                    WHERE p.SaleID = s.SaleID
                ), 0),

            s.PaymentStatus,
            i.InvoiceNo        -- 🔥 thêm mã hóa đơn
        FROM Sales s
        LEFT JOIN Customers c ON c.CustomerID = s.CustomerID
        LEFT JOIN Invoices  i ON i.SaleID     = s.SaleID   -- 🔥 join bảng Invoices
        WHERE
            (
                @search = N''
                OR c.CustomerName LIKE N'%'+@search+N'%'
                OR c.Phone       LIKE N'%'+@search+N'%'
                OR CAST(s.SaleID AS NVARCHAR(20)) LIKE N'%'+@search+N'%'
                OR i.InvoiceNo   LIKE N'%'+@search+N'%'  -- 🔥 search theo InvoiceNo
            )
            AND (@from_date IS NULL OR ISNULL(i.InvoiceDate, s.SaleDate) >= @from_date)
            AND (@to_date   IS NULL OR ISNULL(i.InvoiceDate, s.SaleDate) <  DATEADD(DAY, 1, @to_date))
    )

    SELECT 
        CAST(COUNT(*) OVER() AS BIGINT) AS TotalItems,
        SaleID,
        SaleDate,
        CustomerID,
        CustomerName,
        Phone,
        TotalAmount,
        PaidAmount,
        Remaining,
        PaymentStatus,
        InvoiceNo           -- 🔥 trả thêm về cho FE
    FROM Invoice
    WHERE Remaining > 0    -- chỉ hóa đơn còn nợ
    ORDER BY SaleDate DESC, SaleID DESC
    OFFSET (@page_index - 1) * @page_size ROWS
    FETCH NEXT @page_size ROWS ONLY;
END;
GO





USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_auditlog_create]    Script Date: 11/26/2025 2:07:37 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[sp_auditlog_create]
@UserId int = null,
@Username varchar(50)=null,
@FullName nvarchar(100)=null,
@Action nvarchar(200),
@EntityName nvarchar(100)=null,
@EntityId int =null,
@Operation nvarchar(20),
@Details nvarchar(max)=null
as
begin
set nocount on;
insert into AuditLogs
(UserID,Username,FullName,Action,EntityName,EntityID,Operation,Details)
values
(@UserId,@Username,@FullName,@Action,@EntityName,@EntityId,@Operation,@Details)
select SCOPE_IDENTITY();
end
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_auditlog_get_by_id]    Script Date: 11/26/2025 2:07:48 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[sp_auditlog_get_by_id]
@AuditId int
as
begin
set nocount on
select AuditID,UserID,Username,FullName,Action,EntityName,EntityID,Operation,Details,CreatedAt
from AuditLogs
where AuditID = @AuditId;
end
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_auditlog_search]    Script Date: 11/26/2025 2:07:56 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[sp_auditlog_search]
    @pageIndex INT,
    @pageSize INT,
    @userId INT = NULL,
    @actionKeyword NVARCHAR(200) = NULL,
    @operation NVARCHAR(20) = NULL,
    @fromDate DATETIME2 = NULL,
    @toDate DATETIME2 = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        AuditID, UserID, Username, FullName, Action,
        EntityName, EntityID, Operation, Details, CreatedAt,
        COUNT(*) OVER() AS RecordCount
    FROM AuditLogs
    WHERE (@userId IS NULL OR UserID = @userId)
      AND (@actionKeyword IS NULL OR Action LIKE '%' + @actionKeyword + '%')
      AND (@operation IS NULL OR Operation = @operation)
      AND (@fromDate IS NULL OR CAST(CreatedAt AS DATE) >= CAST(@fromDate AS DATE))
      AND (@toDate IS NULL OR CAST(CreatedAt AS DATE) <= CAST(@toDate AS DATE))
    ORDER BY CreatedAt DESC
    OFFSET (@pageIndex - 1) * @pageSize ROWS
    FETCH NEXT @pageSize ROWS ONLY;
END
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_category_create]    Script Date: 11/26/2025 2:08:08 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
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

    -- Trả về chuỗi rỗng thay vì ID mới
    SELECT '';
END
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_category_delete]    Script Date: 11/26/2025 2:08:18 PM ******/
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

/****** Object:  StoredProcedure [dbo].[sp_category_get_by_id]    Script Date: 11/26/2025 2:08:35 PM ******/
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

/****** Object:  StoredProcedure [dbo].[sp_category_search]    Script Date: 11/26/2025 2:08:46 PM ******/
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

/****** Object:  StoredProcedure [dbo].[sp_category_update]    Script Date: 11/26/2025 2:08:57 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create procedure [dbo].[sp_category_update](
@CategoryID int,
@CategoryName nvarchar(100),
@Description nvarchar(250),
@VATRate decimal (5,3))

as 
begin
update Categories set CategoryName = isnull(@CategoryName,CategoryName),
Description = isnull( @Description,Description),
VATRate = isnull(@VATRate,VATRate)
where CategoryID = @CategoryID
select'';
end
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_customer_create]    Script Date: 11/26/2025 2:09:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create procedure [dbo].[sp_customer_create](
@CustomerName nvarchar(100),
@Phone varchar(20),
@Email nvarchar(100),
@Address nvarchar(200),
@DebtLimit decimal (18,2)
)
as begin
set nocount on
insert into Customers(CustomerName,Phone,Email,Address,DebtLimit) 
values (@CustomerName,@Phone,@Email,@Address,@DebtLimit)
select''
end
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_customer_delete]    Script Date: 11/26/2025 2:09:22 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create procedure [dbo].[sp_customer_delete](@CustomerID int)
as begin
delete from Customers where CustomerID =@CustomerID
select ''
end
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_customer_get_by_id]    Script Date: 11/26/2025 2:09:33 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create procedure [dbo].[sp_customer_get_by_id](@CustomerID int)
as begin
select CustomerID, CustomerName,Phone,Email,Address,DebtLimit 
from Customers where @CustomerID = CustomerID
end
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_customer_search]    Script Date: 11/26/2025 2:09:47 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_customer_search]
    @page_index INT,
    @page_size  INT,
    @Phone      VARCHAR(20)    = '',
    @Address    NVARCHAR(255)  = N''
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH src AS (
        SELECT  
            c.CustomerID,
            c.CustomerName,
            c.Phone,
            c.Email,
            c.[Address],
            c.DebtLimit
        FROM dbo.Customers AS c
        WHERE (@Phone   = ''  OR c.Phone    LIKE '%' + @Phone   + '%')
          AND (@Address = N'' OR c.[Address] LIKE N'%' + @Address + N'%')
    )
    SELECT  
        CAST(COUNT(1) OVER() AS BIGINT) AS RecordCount,
        CustomerID, CustomerName, Phone, Email, [Address], DebtLimit
    FROM src
    ORDER BY CustomerID ASC
    OFFSET (@page_index - 1) * @page_size ROWS
    FETCH NEXT @page_size ROWS ONLY;
END
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_customer_update]    Script Date: 11/26/2025 2:09:56 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[sp_customer_update](@CustomerID int ,@CustomerName nvarchar(100),
@Phone varchar(20),@Email nvarchar(100),@Address nvarchar(255),@DebtLimit decimal(18,2))
as begin
update Customers set 
CustomerName = @CustomerName,
Phone =@Phone,
Email = @Email,
Address =@Address,
DebtLimit =@DebtLimit
where CustomerID = @CustomerID
select ''
end
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_dashboard_top_products]    Script Date: 11/26/2025 2:10:08 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_dashboard_top_products]
(
    @FromDate DATE,
    @ToDate   DATE
)
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH SalesData AS (
        SELECT 
            si.ProductName,
            SUM(si.Quantity) AS TotalQty
        FROM Sales s
        INNER JOIN SalesItems si ON s.SaleID = si.SaleID
        WHERE CAST(s.SaleDate AS DATE) BETWEEN @FromDate AND @ToDate
        GROUP BY si.ProductName
    ),
    Total AS (
        SELECT SUM(TotalQty) AS TotalAll
        FROM SalesData
    )
    SELECT TOP 5
        s.ProductName,
        s.TotalQty,
        CAST((s.TotalQty * 100.0) / t.TotalAll AS DECIMAL(5,2)) AS [Percent]
    FROM SalesData s CROSS JOIN Total t
    ORDER BY s.TotalQty DESC;
END;
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_GoodsIssueDetails_create_multiple]    Script Date: 11/26/2025 2:10:19 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_GoodsIssueDetails_create_multiple]
    @JsonData NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    -- Bảng tạm chứa dữ liệu JSON (không còn BatchNo, cũng không còn UnitPrice)
    DECLARE @TempDetails TABLE (
        IssueID INT,
        ProductID INT,
        Quantity INT
    );

    -- Đổ dữ liệu từ JSON vào bảng tạm
    INSERT INTO @TempDetails
    SELECT 
        IssueID,
        ProductID,
        Quantity
    FROM OPENJSON(@JsonData)
    WITH (
        IssueID INT,
        ProductID INT,
        Quantity INT
    );

    -- Thêm vào bảng chính, tự động lấy ProductName từ bảng Products
    INSERT INTO GoodsIssueDetails (
        IssueID, ProductID, ProductName, Quantity
    )
    SELECT 
        td.IssueID,
        td.ProductID,
        p.ProductName,
        td.Quantity
    FROM @TempDetails td
    INNER JOIN Products p ON td.ProductID = p.ProductID;

    SELECT '' AS message;
END;
GO




USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_GoodsIssueDetails_delete]    Script Date: 11/26/2025 2:10:30 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_GoodsIssueDetails_delete]
(
    @IssueID INT,
    @ProductID INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM GoodsIssueDetails
    WHERE IssueID = @IssueID AND ProductID = @ProductID;

    SELECT '' AS message;
END;
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_GoodsIssueDetails_get_by_IssueID]    Script Date: 11/26/2025 2:10:41 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE  PROCEDURE [dbo].[sp_GoodsIssueDetails_get_by_IssueID]
    @IssueID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        gid.ProductID,
        p.ProductName,
        gid.Quantity
        
    FROM GoodsIssueDetails gid
    INNER JOIN Products p ON gid.ProductID = p.ProductID
    WHERE gid.IssueID = @IssueID
    ORDER BY gid.ProductID;
END


--
SET QUOTED_IDENTIFIER ON
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_GoodsIssues_create]    Script Date: 11/26/2025 2:10:56 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_GoodsIssues_create]
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @NewID INT;

    -- Chỉ còn 2 cột để insert
    INSERT INTO GoodsIssues (UserID, IssueDate)
    VALUES (@UserID, GETDATE());

    SET @NewID = SCOPE_IDENTITY();

    SELECT @NewID AS IssueID;  -- Trả về ID mới tạo
END
GO




USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_GoodsIssues_delete]    Script Date: 11/26/2025 2:11:27 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_GoodsIssues_delete]
(
    @IssueID INT
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Xóa chi tiết phiếu xuất trước (nếu có)
    DELETE FROM GoodsIssueDetails WHERE IssueID = @IssueID;

    -- Sau đó xóa phiếu xuất kho
    DELETE FROM GoodsIssues WHERE IssueID = @IssueID;

    SELECT '' AS message;
END;
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_GoodsIssues_get_by_id]    Script Date: 11/26/2025 2:11:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_GoodsIssues_get_by_id]
(
    @IssueID INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        IssueID,
        IssueDate,
        UserID
        
    FROM GoodsIssues
    WHERE IssueID = @IssueID;
END;
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_GoodsIssues_search]    Script Date: 11/26/2025 2:11:48 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_GoodsIssues_search]
    @page_index INT,
    @page_size INT,
    @UserID INT = NULL,
    @FromDate DATE = NULL,
    @ToDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH FilteredIssues AS (
        SELECT 
            gi.IssueID,
            gi.IssueDate,
            gi.UserID,
            COUNT(*) OVER() AS RecordCount
        FROM GoodsIssues gi
        WHERE 
            (@UserID IS NULL OR gi.UserID = @UserID)
            AND (@FromDate IS NULL OR gi.IssueDate >= @FromDate)
            AND (@ToDate IS NULL OR gi.IssueDate <= @ToDate)
    )
    SELECT *
    FROM FilteredIssues
    ORDER BY IssueID DESC
    OFFSET (@page_index - 1) * @page_size ROWS
    FETCH NEXT @page_size ROWS ONLY;
END;
GO




USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_GoodsIssues_update]    Script Date: 11/26/2025 2:12:00 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_GoodsIssues_update]
(
    @IssueID INT,
    @UserID INT,
    @IssueDate DATETIME
)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE GoodsIssues
    SET
        UserID = @UserID,
        IssueDate = @IssueDate
    WHERE IssueID = @IssueID;

    SELECT '' AS message;
END;
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_GoodsReceiptDetails_create_multiple]    Script Date: 11/26/2025 2:12:11 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_GoodsReceiptDetails_create_multiple]
    @JsonData NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    -- Bảng tạm chứa dữ liệu JSON
    DECLARE @TempDetails TABLE (
        ReceiptID INT,
        ProductID INT,
        Quantity INT,
        UnitPrice DECIMAL(18,2),
        ExpiryDate DATE
    );

    -- Đổ dữ liệu từ JSON vào bảng tạm
    INSERT INTO @TempDetails
    SELECT 
        ReceiptID,
        ProductID,
        Quantity,
        UnitPrice,
        ExpiryDate
    FROM OPENJSON(@JsonData)
    WITH (
        ReceiptID INT,
        ProductID INT,
        Quantity INT,
        UnitPrice DECIMAL(18,2),
        ExpiryDate DATE
    );

    -- Thêm vào bảng chính, tự động lấy ProductName từ bảng Products
    INSERT INTO GoodsReceiptDetails (
        ReceiptID, ProductID, ProductName, Quantity, UnitPrice, ExpiryDate
    )
    SELECT 
        td.ReceiptID,
        td.ProductID,
        p.ProductName,
        td.Quantity,
        td.UnitPrice,
        td.ExpiryDate
    FROM @TempDetails td
    INNER JOIN Products p ON td.ProductID = p.ProductID;

    SELECT ''; -- Tránh lỗi trong C#
END;
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_GoodsReceiptDetails_delete]    Script Date: 11/26/2025 2:12:22 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_GoodsReceiptDetails_delete]
(
    @ReceiptID INT,
    @ProductID INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM GoodsReceiptDetails
    WHERE ReceiptID = @ReceiptID AND ProductID = @ProductID;

    SELECT '' AS message;
END;
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_GoodsReceiptDetails_get_by_receiptid]    Script Date: 11/26/2025 2:12:32 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_GoodsReceiptDetails_get_by_receiptid]
(
    @ReceiptID INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        d.ReceiptID,
        d.ProductID,
        p.ProductName,
        d.Quantity,
        d.UnitPrice,
        d.ExpiryDate
    FROM GoodsReceiptDetails d
    JOIN Products p ON d.ProductID = p.ProductID
    WHERE d.ReceiptID = @ReceiptID;
END;
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_GoodsReceipts_create_multiple]    Script Date: 11/26/2025 2:12:41 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--Stored procedure thêm (create) phiếu nhập kho và bảng GoodsReceipts
CREATE PROCEDURE [dbo].[sp_GoodsReceipts_create_multiple]
    @JsonData NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Today VARCHAR(8) = CONVERT(VARCHAR, GETDATE(), 112);
    DECLARE @Count INT;
    SELECT @Count = COUNT(*) + 1 FROM GoodsReceipts;

    DECLARE @BatchNo VARCHAR(50);
    SET @BatchNo = 'GR-' + @Today + '-' + RIGHT('000' + CAST(@Count AS VARCHAR), 3);

    DECLARE @POID INT, @UserID INT;
    SELECT @POID = POID, @UserID = UserID
    FROM OPENJSON(@JsonData)
    WITH (
        POID INT,
        UserID INT
    );

    INSERT INTO GoodsReceipts (POID, ReceiptDate, UserID, BatchNo)
    VALUES (@POID, GETDATE(), @UserID, @BatchNo);

    -- Trả về ReceiptID mới tạo
    SELECT SCOPE_IDENTITY() AS ReceiptID;
END;
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_GoodsReceipts_delete]    Script Date: 11/26/2025 2:12:57 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_GoodsReceipts_delete]
(
    @ReceiptID INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM GoodsReceipts
    WHERE ReceiptID = @ReceiptID;

    SELECT '' AS message;
END;
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_GoodsReceipts_get_by_id]    Script Date: 11/26/2025 2:13:07 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_GoodsReceipts_get_by_id]
(
    @ReceiptID INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        ReceiptID,
        POID,
        ReceiptDate,
        TotalAmount,
		UserID,
		BatchNo
    FROM GoodsReceipts
    WHERE ReceiptID = @ReceiptID;
END;
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_GoodsReceipts_search]    Script Date: 11/26/2025 2:13:16 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--Stored procedure tìm kiếm (search) phiếu nhập kho 
CREATE PROCEDURE [dbo].[sp_GoodsReceipts_search]
    @page_index INT,
    @page_size INT,
    @MinTotalAmount DECIMAL(18,2) = NULL,
    @MaxTotalAmount DECIMAL(18,2) = NULL,
    @POID INT = NULL,
    @FromDate DATE = NULL,
    @ToDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH FilteredReceipts AS (
        SELECT 
            gr.ReceiptID,
            gr.POID,
            gr.ReceiptDate,
            gr.TotalAmount,
            gr.UserID,
            gr.BatchNo,
            gr.Status, 
            COUNT(*) OVER() AS RecordCount
        FROM GoodsReceipts gr
        WHERE 
            (@MinTotalAmount IS NULL OR gr.TotalAmount >= @MinTotalAmount)
            AND (@MaxTotalAmount IS NULL OR gr.TotalAmount <= @MaxTotalAmount)
            AND (@POID IS NULL OR gr.POID = @POID)
            AND (@FromDate IS NULL OR gr.ReceiptDate >= @FromDate)
            AND (@ToDate IS NULL OR gr.ReceiptDate <= @ToDate)
    )
    SELECT *
    FROM FilteredReceipts
    ORDER BY ReceiptID DESC
    OFFSET (@page_index - 1) * @page_size ROWS
    FETCH NEXT @page_size ROWS ONLY;
END
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_GoodsReceipts_update]    Script Date: 11/26/2025 2:13:25 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_GoodsReceipts_update]
(
    @ReceiptID INT,
    @ReceiptDate DATE,
    @UserID INT
)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE GoodsReceipts
    SET
        ReceiptDate = @ReceiptDate,
        UserID = @UserID
    WHERE ReceiptID = @ReceiptID;

    SELECT '' AS message;
END;
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_Invoice_delete]    Script Date: 11/26/2025 2:13:37 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_Invoice_delete]
(
    @InvoiceID INT
)
AS
BEGIN
    DELETE FROM Invoices
    WHERE InvoiceID = @InvoiceID;

    SELECT '' AS message;
END;
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_Invoice_get_by_id]    Script Date: 11/26/2025 2:13:49 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_Invoice_get_by_id]
(
    @InvoiceID INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        InvoiceID,
        SaleID,
        InvoiceNo,
        InvoiceDate,
        TotalAmount,
        VATAmount
    FROM Invoices
    WHERE InvoiceID = @InvoiceID;
END;
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_payment_create]    Script Date: 11/26/2025 2:13:59 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

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


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_payment_delete]    Script Date: 11/26/2025 2:14:09 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

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


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_payment_get_by_id]    Script Date: 11/26/2025 2:14:19 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
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


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_payment_search]    Script Date: 11/26/2025 2:14:28 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

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


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_payment_update]    Script Date: 11/26/2025 2:14:41 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

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


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_product_create]    Script Date: 11/26/2025 2:14:51 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_product_create]
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


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_product_delete]    Script Date: 11/26/2025 2:15:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
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


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_product_get_by_id]    Script Date: 11/26/2025 2:15:18 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

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


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_product_search]    Script Date: 11/26/2025 2:15:28 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_product_search]
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

            -- ⭐ MỚI: Lấy discount đang áp dụng từ Promotion (giống trigger)
            Discount = ISNULL((
                SELECT TOP 1 pr.Value
                FROM Promotions pr
                WHERE pr.CategoryID = p.CategoryID
                  AND CAST(GETDATE() AS DATE) BETWEEN pr.StartDate AND pr.EndDate
            ), 0),

            ROW_NUMBER() OVER (ORDER BY p.ProductID DESC) AS RowNum,
            COUNT(*) OVER() AS TotalCount
        FROM Products p WITH (NOLOCK)

        WHERE 
            (@ProductID IS NULL OR p.ProductID = @ProductID)
            AND (@SKU = '' OR p.SKU LIKE @SKU + '%')
            AND (@Barcode = '' OR p.Barcode LIKE @Barcode + '%')
            AND (@ProductName = '' OR p.ProductName LIKE N'%' + @ProductName + '%')
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


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_product_update]    Script Date: 11/26/2025 2:15:37 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_product_update]
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


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_Promotions_create]    Script Date: 11/26/2025 2:15:49 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_Promotions_create]
(
    @PromotionName NVARCHAR(100),
    @Type NVARCHAR(50),
    @Value DECIMAL(18,2),
    @StartDate DATE,
    @EndDate DATE,
    @CategoryID INT,
    @Status NVARCHAR(20) = 'Active'  -- mặc định là Active
)
AS
BEGIN
    INSERT INTO Promotions (PromotionName, Type, Value, StartDate, EndDate, CategoryID, Status)
    VALUES (@PromotionName, @Type, @Value, @StartDate, @EndDate, @CategoryID, @Status);

    SELECT '' AS message;
END;
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_Promotions_delete]    Script Date: 11/26/2025 2:15:59 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_Promotions_delete]
(
    @PromotionID INT = NULL
)
AS
BEGIN
    IF @PromotionID IS NULL
    BEGIN
        RAISERROR(N'Bạn phải cung cấp PromotionID để xóa.', 16, 1);
        RETURN;
    END

    DELETE FROM Promotions
    WHERE PromotionID = @PromotionID;

    SELECT '' AS message;
END;
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_Promotions_get_by_id]    Script Date: 11/26/2025 2:16:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_Promotions_get_by_id]
(
    @PromotionID INT
)
AS
BEGIN
    SELECT PromotionID, PromotionName, Type, Value, StartDate, EndDate, CategoryID, Status
    FROM Promotions
    WHERE PromotionID = @PromotionID;
END;
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_Promotions_search]    Script Date: 11/26/2025 2:16:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_Promotions_search]
    @page_index INT,
    @page_size INT,
    @FromDate DATE = NULL,
    @ToDate DATE = NULL,
    @Status NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH FilteredPromotions AS (
        SELECT 
            p.PromotionID,
            p.PromotionName,
            p.Type,
            p.Value,
            p.StartDate,
            p.EndDate,
            p.CategoryID,
            p.Status,
            COUNT(*) OVER() AS RecordCount
        FROM Promotions p
        WHERE 
            (@FromDate IS NULL OR p.StartDate >= @FromDate)
            AND (@ToDate IS NULL OR p.EndDate <= @ToDate)
            AND (@Status IS NULL OR p.Status = @Status)
    )
    SELECT *
    FROM FilteredPromotions
    ORDER BY PromotionID DESC   -- sắp xếp theo ID giảm dần
    OFFSET (@page_index - 1) * @page_size ROWS
    FETCH NEXT @page_size ROWS ONLY;
END;
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_Promotions_update]    Script Date: 11/26/2025 2:16:33 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_Promotions_update]
(
    @PromotionID INT,
    @PromotionName NVARCHAR(100),
    @Type NVARCHAR(50),
    @Value DECIMAL(18,2),
    @StartDate DATE,
    @EndDate DATE,
    @CategoryID INT,
    @Status NVARCHAR(20)   -- thêm tham số Status
)
AS
BEGIN
    UPDATE Promotions
    SET PromotionName = @PromotionName,
        Type = @Type,
        Value = @Value,
        StartDate = @StartDate,
        EndDate = @EndDate,
        CategoryID = @CategoryID,
        Status = @Status     -- cập nhật Status
    WHERE PromotionID = @PromotionID;

    SELECT '' AS message;
END;
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_PurchaseOrderDetails_create_multiple]    Script Date: 11/26/2025 2:16:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_PurchaseOrderDetails_create_multiple]
    @JsonData NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    -- Bảng tạm chứa dữ liệu JSON
    DECLARE @TempDetails TABLE (
        POID INT,
        ProductID INT,
        Quantity INT,
        UnitPrice DECIMAL(18,2)
    );

    -- Đổ dữ liệu từ JSON vào bảng tạm
    INSERT INTO @TempDetails
    SELECT 
        POID,
        ProductID,
        Quantity,
        UnitPrice
    FROM OPENJSON(@JsonData)
    WITH (
        POID INT,
        ProductID INT,
        Quantity INT,
        UnitPrice DECIMAL(18,2)
    );

    -- Thêm vào bảng chính, tự động lấy ProductName từ bảng Products
    INSERT INTO PurchaseOrderDetails (
        POID, ProductID, Quantity, UnitPrice, NameProduct
    )
    SELECT 
        td.POID,
        td.ProductID,
        td.Quantity,
        td.UnitPrice,
        p.ProductName
    FROM @TempDetails td
    INNER JOIN Products p ON td.ProductID = p.ProductID;

    SELECT '' AS message;
END;
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_PurchaseOrderDetails_delete]    Script Date: 11/26/2025 2:16:58 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[sp_PurchaseOrderDetails_delete]
(
    @POID INT,
	@ProductID INT
   
)
AS
BEGIN
    
    DELETE FROM PurchaseOrderDetails
    WHERE POID = @POID AND ProductID = @ProductID;
       ;

    SELECT '' AS message;
END;
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_PurchaseOrderDetails_get_by_poid]    Script Date: 11/26/2025 2:17:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_PurchaseOrderDetails_get_by_poid]
(
    @POID INT
)
AS
BEGIN
    SELECT 
        POID, 
        ProductID, 
        Quantity, 
        UnitPrice, 
        NameProduct,
        (Quantity * UnitPrice) AS TongTien
    FROM PurchaseOrderDetails
    WHERE POID = @POID
    ORDER BY ProductID;
END;
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_PurchaseOrders_create_multiple]    Script Date: 11/26/2025 2:17:21 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_PurchaseOrders_create_multiple]
    @JsonData NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO PurchaseOrders (SupplierID, OrderDate, Status)
    SELECT
        SupplierID,
        GETDATE() AS OrderDate,       -- Tự động lấy ngày hiện tại
        'Pending' AS Status           -- Gán mặc định, có thể đổi thành giá trị khác
    FROM OPENJSON(@JsonData)
    WITH (
        SupplierID INT
    );

    SELECT ''; -- Trả về rỗng để tránh lỗi trong C#
END
GO

drop procedure 

USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_PurchaseOrders_delete]    Script Date: 11/26/2025 2:17:30 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create procedure  [dbo].[sp_PurchaseOrders_delete]
(@POID int)
as
begin delete from PurchaseOrders
where POID = @POID
select '';
end;
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_PurchaseOrders_get_by_id]    Script Date: 11/26/2025 2:17:39 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[sp_PurchaseOrders_get_by_id]
(@POID int)
as
begin
select POID, SupplierID, OrderDate, TotalAmount, Status
from PurchaseOrders
where POID = @POID;
end;
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_PurchaseOrders_search]    Script Date: 11/26/2025 2:17:49 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_PurchaseOrders_search]
    @page_index INT = 1,             -- Trang hiện tại
    @page_size INT = 10,             -- Số dòng mỗi trang
    @MinTotalAmount DECIMAL(18,2) = NULL,
    @MaxTotalAmount DECIMAL(18,2) = NULL,
    @Status NVARCHAR(20) = NULL,
    @FromDate DATE = NULL,
    @ToDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StartRow INT = (@page_index - 1) * @page_size + 1;
    DECLARE @EndRow INT = @page_index * @page_size;

    ;WITH OrderedPO AS
    (
        SELECT 
            ROW_NUMBER() OVER (ORDER BY PO.OrderDate DESC) AS RowNum,
            PO.POID,
            PO.SupplierID,
            PO.OrderDate,
            PO.TotalAmount,
            PO.Status,
            COUNT(*) OVER() AS RecordCount
        FROM PurchaseOrders PO
        WHERE 
            (@MinTotalAmount IS NULL OR PO.TotalAmount >= @MinTotalAmount)
            AND (@MaxTotalAmount IS NULL OR PO.TotalAmount <= @MaxTotalAmount)
            AND (@Status IS NULL OR @Status = '' OR PO.Status = @Status)
            AND (@FromDate IS NULL OR PO.OrderDate >= @FromDate)
            AND (@ToDate IS NULL OR PO.OrderDate <= @ToDate)
    )
    SELECT 
        POID,
        SupplierID,
        OrderDate,
        TotalAmount,
        Status,
        RecordCount
    FROM OrderedPO
    WHERE RowNum BETWEEN @StartRow AND @EndRow
    ORDER BY OrderDate DESC;
END
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_PurchaseOrders_update]    Script Date: 11/26/2025 2:18:00 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[sp_PurchaseOrders_update]
(@POID INT,
@SupplierID int,

@Status nvarchar(20))
as
begin
update PurchaseOrders
set
SupplierID = @SupplierID ,
Status  = @Status 
where POID = @POID;
select '';
end;
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_report_import_export]    Script Date: 11/26/2025 2:18:11 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_report_import_export]
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


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_report_revenue]    Script Date: 11/26/2025 2:18:22 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_report_revenue]
(
    @FromDate DATETIME,
    @ToDate   DATETIME,
    @Option   NVARCHAR(10)  -- 'DAY' | 'MONTH' (hiện tại chưa dùng đến)
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Dùng cho phần FIFO + filter cuối cùng
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
    -- 6. Best Category (bán chạy nhất trong khoảng @FromDate–@ToDate)
    ----------------------------------------------------------------------
    BestCategory AS
    (
        SELECT TOP 1
            c.CategoryID,
            c.CategoryName,
            SUM(si.Quantity) AS TotalQty,     -- số lượng bán trong kỳ
            SUM(si.Quantity * (si.UnitPrice - si.Discount)) AS TotalRevenue
        FROM Sales s
        INNER JOIN SalesItems si ON s.SaleID = si.SaleID
        INNER JOIN Products p    ON si.ProductID = p.ProductID
        INNER JOIN Categories c  ON p.CategoryID = c.CategoryID
        WHERE s.SaleDate >= @FromDate
          AND s.SaleDate <  @ToDateEnd      -- bao trọn ngày @ToDate
        GROUP BY c.CategoryID, c.CategoryName
        ORDER BY TotalQty DESC               -- bán chạy nhất = nhiều qty nhất
    ),

    ----------------------------------------------------------------------
    -- 7. Top Product THEO NGÀY
    ----------------------------------------------------------------------
    DailyProduct AS
    (
        SELECT
            CAST(s.SaleDate AS DATE) AS [Date],
            si.ProductName,
            SUM(si.Quantity) AS TotalQty,
            ROW_NUMBER() OVER(
                PARTITION BY CAST(s.SaleDate AS DATE)
                ORDER BY SUM(si.Quantity) DESC
            ) AS rn
        FROM Sales s
        INNER JOIN SalesItems si ON s.SaleID = si.SaleID
        WHERE CAST(s.SaleDate AS DATE) BETWEEN @FromDate AND @ToDate
        GROUP BY CAST(s.SaleDate AS DATE), si.ProductName
    ),
    DailyTop AS
    (
        SELECT [Date], ProductName
        FROM DailyProduct
        WHERE rn = 1
    ),

    ----------------------------------------------------------------------
    -- 8. Top Product THEO THÁNG (cả kỳ) – group theo ProductID
    ----------------------------------------------------------------------
    MonthlyTop AS
    (
        SELECT TOP 1
            si.ProductID,
            MAX(si.ProductName) AS ProductName,
            SUM(si.Quantity)    AS TotalQty
        FROM Sales s
        INNER JOIN SalesItems si ON s.SaleID = si.SaleID
        WHERE CAST(s.SaleDate AS DATE) BETWEEN @FromDate AND @ToDate
        GROUP BY si.ProductID
        ORDER BY TotalQty DESC
    ),

    ----------------------------------------------------------------------
    -- 9. FinalData: doanh thu & lợi nhuận theo ngày
    ----------------------------------------------------------------------
    FinalData AS
    (
        SELECT
            CAST(s.SaleDate AS DATE) AS [Date],
            SUM(rps.Revenue) AS Revenue,
            SUM(rps.Revenue - ISNULL(cps.COGS,0)) AS GrossProfit
        FROM Sales s
        INNER JOIN RevenuePerSale rps ON s.SaleID = rps.SaleID
        LEFT  JOIN CogsPerSale   cps ON s.SaleID = cps.SaleID
        WHERE CAST(s.SaleDate AS DATE) BETWEEN @FromDate AND @ToDate
        GROUP BY CAST(s.SaleDate AS DATE)
    ),

    ----------------------------------------------------------------------
    -- 10. DateRange: sinh đủ ngày trong khoảng
    ----------------------------------------------------------------------
    DateRange AS
    (
        SELECT CAST(@FromDate AS DATE) AS [Date]
        UNION ALL
        SELECT DATEADD(DAY, 1, [Date])
        FROM DateRange
        WHERE DATEADD(DAY, 1, [Date]) <= CAST(@ToDate AS DATE)
    )

    ----------------------------------------------------------------------
    -- 11. OUTPUT CUỐI
    ----------------------------------------------------------------------
    SELECT
        CONVERT(NVARCHAR(10), d.Date, 23) AS [Date],
        ISNULL(f.Revenue, 0)     AS Revenue,
        ISNULL(f.GrossProfit, 0) AS GrossProfit,

        (SELECT TOP 1 CategoryName FROM BestCategory) AS BestCategory,     -- category bán chạy nhất trong kỳ
        ISNULL(dt.ProductName, N'')                   AS DailyTopProduct,  -- top product theo ngày
        (SELECT TOP 1 ProductName FROM MonthlyTop)    AS MonthlyTopProduct -- top product cả kỳ

    FROM DateRange d
    LEFT JOIN FinalData f ON d.Date = f.[Date]
    LEFT JOIN DailyTop  dt ON d.Date = dt.[Date]
    ORDER BY d.Date
    OPTION (MAXRECURSION 0);
END;
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_report_stock]    Script Date: 11/26/2025 2:18:32 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_report_stock]
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

/****** Object:  StoredProcedure [dbo].[sp_return_create]    Script Date: 11/26/2025 2:18:41 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

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


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_return_delete]    Script Date: 11/26/2025 2:18:50 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

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


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_return_get_by_id]    Script Date: 11/26/2025 2:19:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

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


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_return_search]    Script Date: 11/26/2025 2:19:16 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

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


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_return_update]    Script Date: 11/26/2025 2:19:32 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
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


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_Sales_create]    Script Date: 11/26/2025 2:19:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_Sales_create]
(
    @CustomerID INT,
    @UserID INT
)
AS
BEGIN
    INSERT INTO Sales (CustomerID, UserID, SaleDate)
    VALUES (@CustomerID, @UserID, GETDATE());  -- tự động lấy ngày giờ hiện tại

    SELECT '';
END;
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_sales_create_return_id]    Script Date: 11/26/2025 2:19:52 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[sp_sales_create_return_id](@CustomerId int, @UserId int)
as 
begin
set nocount on
insert into Sales(CustomerID,UserID,SaleDate,PaymentStatus)
values(@CustomerId, @UserId, GETDATE(),'Unpaid');
select cast(SCOPE_IDENTITY() as int) as SaleID;
end
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_Sales_dashboard]    Script Date: 11/26/2025 2:20:04 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[sp_Sales_dashboard]
    @MinTotalAmount DECIMAL(18,2) = NULL,
    @MaxTotalAmount DECIMAL(18,2) = NULL,
    @Status         NVARCHAR(50) = NULL,
    @FromDate       DATETIME = NULL,
    @ToDate         DATETIME = NULL,
    @Keyword        NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH Filtered AS (
        SELECT 
            s.SaleID, 
            s.TotalAmount, 
            s.PaymentStatus, 
            s.SaleDate,
            c.CustomerName, 
            i.InvoiceNo
        FROM   Sales s
        LEFT JOIN Invoices  i ON i.SaleID = s.SaleID
        LEFT JOIN Customers c ON c.CustomerID = s.CustomerID
        WHERE  (@MinTotalAmount IS NULL OR s.TotalAmount >= @MinTotalAmount)
           AND (@MaxTotalAmount IS NULL OR s.TotalAmount <= @MaxTotalAmount)
           AND (@Status IS NULL OR s.PaymentStatus = @Status)
           AND (@FromDate IS NULL OR s.SaleDate >= @FromDate)
           AND (@ToDate   IS NULL OR s.SaleDate < DATEADD(DAY,1,@ToDate))
           AND (
                @Keyword IS NULL
             OR i.InvoiceNo    LIKE '%' + @Keyword + '%'
             OR c.CustomerName LIKE '%' + @Keyword + '%'
           )
    )
    SELECT 
        TotalSales    = COUNT(1),
        TotalRevenue  = ISNULL(SUM(F.TotalAmount), 0),
        AvgOrderValue = CASE WHEN COUNT(1) = 0 THEN 0 
                             ELSE ISNULL(SUM(F.TotalAmount),0) * 1.0 / COUNT(1) 
                        END,
        PaidCount   = ISNULL(SUM(CASE WHEN F.PaymentStatus = 'Paid' THEN 1 ELSE 0 END), 0),
        UnpaidCount = ISNULL(SUM(CASE WHEN F.PaymentStatus <> 'Paid' 
                                      OR F.PaymentStatus IS NULL THEN 1 ELSE 0 END), 0)
    FROM Filtered AS F;
END
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_Sales_delete]    Script Date: 11/26/2025 2:20:14 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create procedure  [dbo].[sp_Sales_delete]
(@SaleID INT)
as
begin 
delete from Sales
where SaleID = @SaleID;
select '';
end;
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_Sales_detail_header]    Script Date: 11/26/2025 2:20:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[sp_Sales_detail_header]
    @SaleID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 1
        s.SaleID,
        i.InvoiceNo,
        s.SaleDate,
        c.CustomerID,
        c.CustomerName,
        c.Phone AS CustomerPhone,
        u.UserID,
        u.FullName AS CashierName,
        s.PaymentStatus,
        -- lấy method của lần thanh toán gần nhất (nếu có)
        p.Method AS PaymentMethod
    FROM Sales s
    LEFT JOIN Customers c ON s.CustomerID = c.CustomerID
    LEFT JOIN Users u ON s.UserID = u.UserID
    LEFT JOIN Invoices i ON i.SaleID = s.SaleID
    OUTER APPLY (
        SELECT TOP 1 Method
        FROM Payments
        WHERE SaleID = s.SaleID
        ORDER BY PaymentDate DESC, PaymentID DESC
    ) p
    WHERE s.SaleID = @SaleID;
END
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_Sales_detail_items]    Script Date: 11/26/2025 2:20:33 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[sp_Sales_detail_items]
    @SaleID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        si.SaleID,
        si.ProductID,
        si.ProductName,
        p.SKU,
        si.Quantity,
        si.UnitPrice,
        si.Discount,                    -- % giảm
        ISNULL(p.VATRate, 0) AS VatPercent,
        -- Thành tiền sau discount, chưa cộng VAT (cho FE dùng)
        (si.Quantity * si.UnitPrice * (1 - si.Discount / 100.0)) AS LineTotal
    FROM SalesItems si
    INNER JOIN Products p ON si.ProductID = p.ProductID
    WHERE si.SaleID = @SaleID;
END
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_Sales_detail_totals]    Script Date: 11/26/2025 2:20:46 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[sp_Sales_detail_totals]
    @SaleID INT
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH LineCTE AS (
        SELECT
            si.SaleID,
            si.Quantity,
            si.UnitPrice,
            si.Discount,
            LineAfterDiscount = si.Quantity * si.UnitPrice * (1 - si.Discount / 100.0)
        FROM SalesItems si
        WHERE si.SaleID = @SaleID
    )
    SELECT
        Subtotal   = ISNULL(SUM(LineAfterDiscount), 0),
        VatAmount  = ISNULL(s.VATAmount, 0),
        VatPercent = CASE 
                        WHEN ISNULL(SUM(LineAfterDiscount), 0) = 0 
                             OR ISNULL(s.VATAmount, 0) = 0 THEN 0
                        ELSE (s.VATAmount * 100.0) / SUM(LineAfterDiscount)
                     END,
        Total      = ISNULL(s.TotalAmount, 0),
        CustomerPaid = ISNULL(
            (SELECT SUM(Amount) FROM Payments WHERE SaleID = s.SaleID),
            0
        )
    FROM Sales s
    LEFT JOIN LineCTE l ON s.SaleID = l.SaleID
    WHERE s.SaleID = @SaleID
    GROUP BY s.SaleID, s.VATAmount, s.TotalAmount;
END
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_Sales_get_by_id]    Script Date: 11/26/2025 2:20:55 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[sp_Sales_get_by_id]
(@SaleID INT)
as
begin
select SaleID, CustomerID, UserID, SaleDate, TotalAmount, VATAmount, PaymentStatus
from Sales 
where SaleID = @SaleID;
end;
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_Sales_list_view]    Script Date: 11/26/2025 2:21:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[sp_Sales_list_view]
    @page_index INT,
    @page_size INT,
    @Status NVARCHAR(20) = NULL,
    @FromDate DATETIME = NULL,
    @ToDate DATETIME = NULL,
    @Keyword NVARCHAR(200) = NULL    -- invoice / customer
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH Filtered AS (
        SELECT 
            s.SaleID,
            s.SaleDate,
            s.TotalAmount,
            s.PaymentStatus,

            c.CustomerID,
            c.CustomerName,

            i.InvoiceNo,

            -- nếu sau này có payment method:
            pm.Method AS PaymentMethod,

            COUNT(*) OVER() AS RecordCount
        FROM Sales s
        LEFT JOIN Customers c ON c.CustomerID = s.CustomerID
        LEFT JOIN Invoices  i ON i.SaleID     = s.SaleID
        LEFT JOIN Payments  pm ON pm.SaleID   = s.SaleID
            AND pm.PaymentID = (
                SELECT TOP 1 PaymentID 
                FROM Payments 
                WHERE SaleID = s.SaleID 
                ORDER BY PaymentDate DESC
            )

        WHERE
            (@Status IS NULL OR s.PaymentStatus = @Status)
            AND (@FromDate IS NULL OR s.SaleDate >= @FromDate)
            AND (@ToDate   IS NULL OR s.SaleDate <= @ToDate)
            AND (
                @Keyword IS NULL
                OR i.InvoiceNo    LIKE '%' + @Keyword + '%'
                OR c.CustomerName LIKE '%' + @Keyword + '%'
            )
    )
    SELECT *
    FROM Filtered
    ORDER BY SaleDate DESC
    OFFSET (@page_index - 1) * @page_size ROWS
    FETCH NEXT @page_size ROWS ONLY;
END
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_Sales_search]    Script Date: 11/26/2025 2:21:15 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_Sales_search]
    @page_index INT,
    @page_size INT,
    @MinTotalAmount DECIMAL(18,2) = NULL,
    @MaxTotalAmount DECIMAL(18,2) = NULL,
    @Status NVARCHAR(20) = NULL,
    @FromDate DATETIME = NULL,
    @ToDate DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH FilteredSales AS (
        SELECT 
            s.SaleID,
            s.CustomerID,
            s.UserID,
            s.SaleDate,
            s.TotalAmount,
            s.VATAmount,
            s.PaymentStatus,
            COUNT(*) OVER() AS RecordCount
        FROM Sales s
        WHERE 
            (@MinTotalAmount IS NULL OR s.TotalAmount >= @MinTotalAmount)
            AND (@MaxTotalAmount IS NULL OR s.TotalAmount <= @MaxTotalAmount)
            AND (@Status IS NULL OR s.PaymentStatus = @Status)
            AND (@FromDate IS NULL OR s.SaleDate >= @FromDate)
            AND (@ToDate IS NULL OR s.SaleDate <= @ToDate)
    )
    SELECT *
    FROM FilteredSales
    ORDER BY SaleDate DESC
    OFFSET (@page_index - 1) * @page_size ROWS
    FETCH NEXT @page_size ROWS ONLY;
END;
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_Sales_update]    Script Date: 11/26/2025 2:21:25 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[sp_Sales_update]
(  @SaleID INT,
    @CustomerID INT,
    @UserID INT,
    @SaleDate DATETIME,
    @PaymentStatus NVARCHAR(20)
   
	)
as
begin
update Sales
set 
CustomerID = @CustomerID,
UserID = @UserID,
SaleDate = @SaleDate,
PaymentStatus = @PaymentStatus
where SaleID = @SaleID;
select '';
end;
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_SalesItem_create_multiple]    Script Date: 11/26/2025 2:21:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_SalesItem_create_multiple]
    @JsonData NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    -- Bảng tạm chứa dữ liệu JSON
    DECLARE @TempItems TABLE (
        SaleID INT,
        ProductID INT,
        Quantity INT
    );

    -- Đổ dữ liệu từ JSON vào bảng tạm
    INSERT INTO @TempItems
    SELECT 
        SaleID,
        ProductID,
        Quantity
    FROM OPENJSON(@JsonData)
    WITH (
        SaleID INT,
        ProductID INT,
        Quantity INT
    );

    -- Thêm vào bảng chính, lấy ProductName và UnitPrice từ bảng Products
    INSERT INTO SalesItems (
        SaleID, ProductID, ProductName, Quantity, UnitPrice, Discount
    )
    SELECT 
        ti.SaleID,
        ti.ProductID,
        p.ProductName,
        ti.Quantity,
        p.UnitPrice,       -- Lấy giá từ bảng Products
        0 AS Discount
    FROM @TempItems ti
    INNER JOIN Products p ON ti.ProductID = p.ProductID;

    SELECT ''; -- Tránh lỗi trong C#
END;
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_SalesItem_delete]    Script Date: 11/26/2025 2:21:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_SalesItem_delete]
(
    @SaleID INT,
    @ProductID INT
)
AS
BEGIN
    DELETE FROM SalesItems
    WHERE SaleID = @SaleID AND ProductID = @ProductID;

    SELECT '' AS message;
END;
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_SalesItem_get_by_id]    Script Date: 11/26/2025 2:21:53 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_SalesItem_get_by_id]
(
    @SaleID INT,
    @ProductID INT
)
AS
BEGIN
    SELECT SaleID, ProductID, ProductName, Quantity, UnitPrice, Discount
    FROM SalesItems
    WHERE SaleID = @SaleID AND ProductID = @ProductID;
END;
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_settings_get]    Script Date: 11/26/2025 2:22:03 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_settings_get]
AS
BEGIN
    SELECT SettingID, VATRate, DefaultLanguage, LastUpdated
    FROM Settings;
END

GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_settings_update]    Script Date: 11/26/2025 2:22:11 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_settings_update]
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
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_stockcard_create]    Script Date: 11/26/2025 2:22:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

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


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_stockcard_delete]    Script Date: 11/26/2025 2:22:33 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


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


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_stockcard_get_by_id]    Script Date: 11/26/2025 2:22:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

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


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_stockcard_search]    Script Date: 11/26/2025 2:22:53 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


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


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_supplier_create]    Script Date: 11/26/2025 2:23:21 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



create procedure [dbo].[sp_supplier_create](@SupplierName nvarchar(100),@Address nvarchar(255),@Phone varchar(20),@Email nvarchar(100))
as
begin
set nocount on
insert into Suppliers (SupplierName,[Address],Phone,Email)
values (@SupplierName,@Address,@Phone,@Email)
select''
end
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_supplier_delete]    Script Date: 11/26/2025 2:23:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

 create procedure [dbo].[sp_supplier_delete](@SupplierID int)
 as begin delete from Suppliers where SupplierID = @SupplierID
 select''
 end
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_supplier_get_by_id]    Script Date: 11/26/2025 2:23:48 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[sp_supplier_get_by_id](
@SupplierID int
)
as begin
Select SupplierID, SupplierName,Address,Phone,Email
from Suppliers where SupplierID = @SupplierID
end
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_supplier_search]    Script Date: 11/26/2025 2:23:57 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_supplier_search]
    @page_index INT,
    @page_size  INT,
    @Phone      VARCHAR(20) = ''
AS
BEGIN
    SET NOCOUNT ON;

    SELECT CAST(COUNT(1) OVER() AS BIGINT) AS RecordCount,
           src.SupplierID, src.SupplierName, src.Address, src.Phone, src.Email
    FROM (
        SELECT s.SupplierID, s.SupplierName, s.Address, s.Phone, s.Email
        FROM dbo.Suppliers AS s
        WHERE (@Phone = '' OR s.Phone LIKE '%' + @Phone + '%')
    ) AS src
    ORDER BY src.SupplierID ASC
    OFFSET (@page_index - 1) * @page_size ROWS
    FETCH NEXT @page_size ROWS ONLY;
END

GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_supplier_update]    Script Date: 11/26/2025 2:24:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[sp_supplier_update](@SupplierID int,@SupplierName nvarchar(100), @Address nvarchar(255),@Phone varchar(20),@Email nvarchar(100))
as begin Update Suppliers set
SupplierName = isnull( @SupplierName,SupplierName),
[Address]= isnull(@Address,Address),
Phone= isnull(@Phone,Phone),
Email = isnull(@Email, Email) 
where SupplierID = @SupplierID
select''
end
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_user_create]    Script Date: 11/26/2025 2:24:15 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
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

/****** Object:  StoredProcedure [dbo].[sp_user_delete]    Script Date: 11/26/2025 2:24:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[sp_user_delete](@UserId int)
as
begin delete from [Users] where UserID = @UserId
select ''
end
GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_user_get_by_id]    Script Date: 11/26/2025 2:24:34 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
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

/****** Object:  StoredProcedure [dbo].[sp_user_get_by_username_password]    Script Date: 11/26/2025 2:24:46 PM ******/
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


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_user_search]    Script Date: 11/26/2025 2:24:57 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_user_search]
(
    @pageIndex INT,
    @pageSize INT,
    @keyword NVARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RecordCount BIGINT;

    SELECT ROW_NUMBER() OVER (ORDER BY UserID ASC) AS RowNumber,
           UserID,
           Username,
           PasswordHash,
           Role,
           FullName,
           Email,
           Phone
    INTO #Results
    FROM Users
    WHERE Username <> 'Admin'
      AND (@keyword = '' OR FullName LIKE '%' + @keyword + '%' OR Username LIKE '%' + @keyword + '%');

    SELECT @RecordCount = COUNT(*) FROM #Results;

    SELECT *,
           @RecordCount AS RecordCount
    FROM #Results
    WHERE RowNumber BETWEEN (@pageIndex - 1) * @pageSize + 1
                         AND @pageIndex * @pageSize;

    DROP TABLE #Results;
END

GO


USE [QLBanLeKho]
GO

/****** Object:  StoredProcedure [dbo].[sp_user_update]    Script Date: 11/26/2025 2:25:06 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
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


