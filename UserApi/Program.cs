using BLL.Interfaces;
using BLL;
using DAL.Interfaces;
using DAL;
using DAL.Helper;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// // Đăng ký các lớp xử lý nghiệp vụ và truy cập dữ liệu vào hệ thống DI
builder.Services.AddScoped<IDatabaseHelper, DatabaseHelper>();
builder.Services.AddScoped<IDonMuaHangBusiness, DonMuaHangBusiness>();
builder.Services.AddScoped<IDonMuaHangRepository, DonMuaHangRepository>();


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
