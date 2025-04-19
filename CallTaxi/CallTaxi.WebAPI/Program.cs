using eCommerce.Services;
using eCommerce.Services.Database;
using Mapster;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddTransient<IProductService, ProductService>();
builder.Services.AddTransient<IUserService, UserService>();
//builder.Services.AddTransient<IProductTypeService, ProductTypeService>();

builder.Services.AddMapster();
// Configure database
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection") ?? "Data Source=.;Database=CallTaxiDb;User Id=your_user;Password=your_password;TrustServerCertificate=True;Trusted_Connection=True;";
builder.Services.AddDatabaseServices(connectionString);

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Ensure database is created
//using (var scope = app.Services.CreateScope())
//{
//    var dbContext = scope.ServiceProvider.GetRequiredService<CallTaxiDbContext>();
//    dbContext.Database.EnsureCreated();
//}

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
