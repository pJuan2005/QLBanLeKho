using BLL;
using DAL.Helper;
using DAL;
using BLL.Interfaces;
using Helper;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using DAL.Interfaces;
using AdminApi.Services;
using AdminApi.Services.Interface;
using CoreApi.Services;


var builder = WebApplication.CreateBuilder(args);
builder.Services.AddMemoryCache();
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", builder => builder.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader());
});

// Add services to the container.
builder.Services.AddTransient<IDatabaseHelper, DatabaseHelper>();
builder.Services.AddTransient<ICategoryRepository, CategoryRepository>();
builder.Services.AddTransient<ICategoryBusiness, CategoryBusiness>();
builder.Services.AddTransient<IUserBusiness, UserBusiness>();
builder.Services.AddTransient<IUserRepository, UserRepository>();
builder.Services.AddTransient<ICustomerRepository, CustomerRepository>();
builder.Services.AddTransient<ICustomerBusiness, CustomerBusiness>();
builder.Services.AddTransient<IArCustomerBusiness, ArCustomerBusiness>();
builder.Services.AddTransient<IArCustomerRepository,ArCustomerRepository>();
builder.Services.AddTransient<IApSupplierRepository, ApSupplierRepository>();
builder.Services.AddTransient<IApSupplierBusiness, ApSupplierBusiness>();
builder.Services.AddHttpContextAccessor();
builder.Services.AddTransient<IAuditLogger, AuditLogger>();
builder.Services.AddTransient<IAuditLogRepository, AuditLogRepository>();
builder.Services.AddTransient<IAuditLogBusiness, AuditLogBusiness>();

// Đăng ký các lớp xử lý nghiệp vụ và truy cập dữ liệu vào hệ thống DI <PurchaseOrderDetails>
builder.Services.AddTransient<IPurchaseOrderDetailsBusiness, PurchaseOrderDetailsBusiness>();
builder.Services.AddTransient<IPurchaseOrderDetailsRepository, PurchaseOrderDetailsRepository>();

// Đăng ký các lớp xử lý nghiệp vụ và truy cập dữ liệu vào hệ thống DI <Promotions>
builder.Services.AddTransient<IPromotionsBusiness, PromotionsBusiness>();
builder.Services.AddTransient<IPromotionsRepository, PromotionsRepository>();

// Đăng ký các lớp xử lý nghiệp vụ và truy cập dữ liệu vào hệ thống DI <Sales>

builder.Services.AddTransient<ISalesBusiness, SalesBusiness>();
builder.Services.AddTransient<ISalesRepository, SalesRepository>();

// Đăng ký các lớp xử lý nghiệp vụ và truy cập dữ liệu vào hệ thống DI <SalesItem>

builder.Services.AddTransient<ISalesItemBusiness, SalesItemBusiness>();
builder.Services.AddTransient<ISalesItemRepository, SalesItemRepository>();

// Đăng ký các lớp xử lý nghiệp vụ và truy cập dữ liệu vào hệ thống DI <Invoice>
builder.Services.AddTransient<IInvoiceBusiness, InvoiceBusiness>();
builder.Services.AddTransient<IInvoiceRepository, InvoiceRepository>();

// Đăng ký các lớp xử lý nghiệp vụ và truy cập dữ liệu vào hệ thống DI <GoodsReceipts>
builder.Services.AddTransient<IGoodsReceiptsBusiness, GoodsReceiptsBusiness>();
builder.Services.AddTransient<IGoodsReceiptsRepository, GoodsReceiptsRepository>();

// Đăng ký các lớp xử lý nghiệp vụ và truy cập dữ liệu vào hệ thống DI <GoodsReceiptDetails>
builder.Services.AddTransient<IGoodsReceiptDetailsBusiness, GoodsReceiptDetailsBusiness>();
builder.Services.AddTransient<IGoodsReceiptDetailsRepository, GoodsReceiptDetailsRepository>();

// Đăng ký các lớp xử lý nghiệp vụ và truy cập dữ liệu vào hệ thống DI <GoodsIssues>
builder.Services.AddTransient<IGoodsIssuesBusiness, GoodsIssuesBusiness>();
builder.Services.AddTransient<IGoodsIssuesRepository, GoodsIssuesRepository>();

// Đăng ký các lớp xử lý nghiệp vụ và truy cập dữ liệu vào hệ thống DI <GoodsIssueDetails>
builder.Services.AddTransient<IGoodsIssueDetailsBusiness, GoodsIssueDetailsBusiness>();
builder.Services.AddTransient<IGoodsIssueDetailsRepository, GoodsIssueDetailsRepository>();

// Đăng ký các lớp xử lý nghiệp vụ và truy cập dữ liệu vào hệ thống DI <PurchaseOrder>

builder.Services.AddTransient<IPurchaseOrderBusiness, PurchaseOrderBusiness>();
builder.Services.AddScoped<IPurchaseOrderRepository, PurchaseOrderRepository>();




builder.Services.AddScoped<IReturnBLL, ReturnBLL>();
builder.Services.AddScoped<IReturnDAL, ReturnDAL>();



// configure strongly typed settings objects
IConfiguration configuration = builder.Configuration;
var appSettingsSection = configuration.GetSection("AppSettings");
builder.Services.Configure<AppSettings>(appSettingsSection);
//configure jwt authentication
var appSettings = appSettingsSection.Get<AppSettings>();
var key = Encoding.ASCII.GetBytes(appSettings.Secret);
builder.Services.AddAuthentication(x =>
{
    x.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    x.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
}).AddJwtBearer(x =>
{
    x.RequireHttpsMetadata = false;
    x.SaveToken = true;
    x.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuerSigningKey = true,
        IssuerSigningKey = new SymmetricSecurityKey(key),
        ValidateIssuer = false,
        ValidateAudience = false
    };
});



builder.Services.AddTransient<IDProductDAL, ProductDAL>();
builder.Services.AddTransient<IDProductBLL, ProductBLL>();



builder.Services.AddTransient<IDPaymentDAL, PaymentDAL>();
builder.Services.AddTransient<IDPaymentBLL, PaymentBLL>();



builder.Services.AddTransient<IDStockCardDAL, StockCardDAL>();
builder.Services.AddTransient<IDStockCardBLL, StockCardBLL>();


builder.Services.AddTransient<IDReportDAL, ReportDAL>();
builder.Services.AddTransient<IDReportBLL, ReportBLL>();




builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();


// Pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

//app.UseHttpsRedirection();

app.UseStaticFiles();

app.UseRouting();

app.UseCors("AllowAll");


// Nếu auth đã được cấu hình (secret != null) bật authentication middleware
if (appSettings != null && !string.IsNullOrWhiteSpace(appSettings.Secret))
{
    app.UseAuthentication();
    app.UseAuthorization();
}

// Map controllers
app.MapControllers();

app.Run();