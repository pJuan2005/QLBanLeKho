using BLL;
using DAL.Helper;
using DAL;
using BLL.Interfaces;
using Helper;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using DAL.Interfaces;




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

// Đăng ký các lớp xử lý nghiệp vụ và truy cập dữ liệu vào hệ thống DI <PurchaseOrderDetails>
builder.Services.AddScoped<IPurchaseOrderDetailsBusiness, PurchaseOrderDetailsBusiness>();
builder.Services.AddScoped<IPurchaseOrderDetailsRepository, PurchaseOrderDetailsRepository>();

// Đăng ký các lớp xử lý nghiệp vụ và truy cập dữ liệu vào hệ thống DI <Promotions>
builder.Services.AddScoped<IPromotionsBusiness, PromotionsBusiness>();
builder.Services.AddScoped<IPromotionsRepository, PromotionsRepository>();

// Đăng ký các lớp xử lý nghiệp vụ và truy cập dữ liệu vào hệ thống DI <Sales>

builder.Services.AddScoped<ISalesBusiness, SalesBusiness>();
builder.Services.AddScoped<ISalesRepository, SalesRepository>();

// Đăng ký các lớp xử lý nghiệp vụ và truy cập dữ liệu vào hệ thống DI <SalesItem>

builder.Services.AddScoped<ISalesItemBusiness, SalesItemBusiness>();
builder.Services.AddScoped<ISalesItemRepository, SalesItemRepository>();

// Đăng ký các lớp xử lý nghiệp vụ và truy cập dữ liệu vào hệ thống DI <Invoice>
builder.Services.AddScoped<IInvoiceBusiness, InvoiceBusiness>();
builder.Services.AddScoped<IInvoiceRepository, InvoiceRepository>();

// Đăng ký các lớp xử lý nghiệp vụ và truy cập dữ liệu vào hệ thống DI <GoodsReceipts>
builder.Services.AddScoped<IGoodsReceiptsBusiness, GoodsReceiptsBusiness>();
builder.Services.AddScoped<IGoodsReceiptsRepository, GoodsReceiptsRepository>();

// Đăng ký các lớp xử lý nghiệp vụ và truy cập dữ liệu vào hệ thống DI <GoodsReceiptDetails>
builder.Services.AddScoped<IGoodsReceiptDetailsBusiness, GoodsReceiptDetailsBusiness>();
builder.Services.AddScoped<IGoodsReceiptDetailsRepository, GoodsReceiptDetailsRepository>();

// Đăng ký các lớp xử lý nghiệp vụ và truy cập dữ liệu vào hệ thống DI

builder.Services.AddScoped<IDonMuaHangBusiness, DonMuaHangBusiness>();
builder.Services.AddScoped<IDonMuaHangRepository, DonMuaHangRepository>();



builder.Services.AddScoped<IDReturnBLL, ReturnBLL>();
builder.Services.AddScoped<IDReturnDAL, ReturnDAL>();



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

builder.Services.AddTransient<IDReturnBLL, ReturnBLL>();
builder.Services.AddTransient<IDReturnDAL, ReturnDAL>();

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

app.UseHttpsRedirection();

app.UseStaticFiles();

app.UseRouting();

app.UseCors("AllowAll");

app.UseDefaultFiles(); // Tìm file mặc định như index.html
app.UseStaticFiles();  // Phục vụ các file tĩnh từ wwwroot (bao gồm index.html và ảnh)


// Nếu auth đã được cấu hình (secret != null) bật authentication middleware
if (appSettings != null && !string.IsNullOrWhiteSpace(appSettings.Secret))
{
    app.UseAuthentication();
    app.UseAuthorization();
}

// Map controllers
app.MapControllers();

app.Run();