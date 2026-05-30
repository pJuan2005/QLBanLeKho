# Retail POS & Inventory Management System

A Retail POS (Point of Sale) and Inventory Management System developed using ASP.NET Core Web API and SQL Server.

## Overview

This project was developed as a Software Development course project at Hung Yen University of Technology and Education.

The system helps retail stores manage:

- Product catalog
- Inventory
- Sales orders
- Purchase orders
- Goods receipts
- Goods issues
- Customers
- Suppliers
- Promotions
- Payments & Debts
- Reports & Dashboard
- User management and authorization

---

## Technologies

### Backend

- ASP.NET Core Web API
- Entity Framework Core
- SQL Server
- JWT Authentication

### Frontend

- AngularJS
- HTML
- CSS
- JavaScript

### Other Tools

- Swagger
- Chart.js
- Git & GitHub

---

## System Architecture

```text
Client (AngularJS)
        |
        v
ASP.NET Core Web API
        |
        v
Business Logic Layer
        |
        v
Data Access Layer
        |
        v
SQL Server
```

## Main Features

### Authentication & Authorization

- Login
- JWT Authentication
- Role-based Authorization

Roles:

- Admin
- Cashier
- Warehouse Staff
- Accountant

---

### Inventory Management

- Goods Receipts
- Goods Issues
- Stock Cards
- Inventory Tracking

---

### Sales Management

- POS System
- Sales Orders
- Invoice Management
- Return Orders

---

### Product Management

- Categories
- Products
- SKU / Barcode
- Pricing

---

### Customer & Supplier Management

- Customer Profiles
- Supplier Profiles
- Purchase History

---

### Promotion Management

- Percentage Discounts
- Fixed Amount Discounts
- Time-based Promotions

---

### Reports & Dashboard

- Revenue Reports
- Profit Reports
- Inventory Reports
- Best-selling Products
- KPI Dashboard

---

## Database

SQL Server

Main entities:

- Users
- Products
- Categories
- Customers
- Suppliers
- Sales
- PurchaseOrders
- GoodsReceipts
- GoodsIssues
- Payments
- Promotions
- AuditLogs

---

## Screenshots

### Dashboard

(Add screenshot here)

### POS

(Add screenshot here)

### Inventory Management

(Add screenshot here)

### Reports

(Add screenshot here)

---

## Installation

### Clone Repository

```bash
git clone https://github.com/pJuan2005/QLBanLe_API.git
```

### Configure Database

Update:

```json
appsettings.json
```

```json
ConnectionStrings
```

### Apply Migration

```bash
dotnet ef database update
```

### Run Project

```bash
dotnet run
```

---

## Author

Pham Xuan Chuan

Software Engineering Student

ASP.NET Core | ReactJS | NextJS | NodeJS | TypeScript
