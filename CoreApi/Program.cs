using BLL;
using BLL.Interfaces;
using DAL;
using DAL.Helper;
using DAL.Interfaces;



var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddTransient<IDatabaseHelper, DatabaseHelper>();
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

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
