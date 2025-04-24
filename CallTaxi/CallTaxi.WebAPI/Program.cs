using eCommerce.Services;
using eCommerce.Services.Database;
using eCommerce.WebAPI.Filters;
using Mapster;
using Microsoft.AspNetCore.Authentication;
using Microsoft.OpenApi.Models;
using CallTaxi.Services;
using eCommerce.Services.ProductStateMachine;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddTransient<IProductService, ProductService>();
builder.Services.AddTransient<IUserService, UserService>();
//builder.Services.AddTransient<IProductTypeService, ProductTypeService>();
builder.Services.AddTransient<IRoleService, RoleService>();

// State Machine
builder.Services.AddTransient<BaseVehicleState>();
builder.Services.AddTransient<InitialVehicleState>();
builder.Services.AddTransient<DraftVehicleState>();
//builder.Services.AddTransient<ActiveProductState>();
//builder.Services.AddTransient<DeactivatedProductState>();

// Add new services
builder.Services.AddTransient<IBrandService, BrandService>();
builder.Services.AddTransient<IVehicleTierService, VehicleTierService>();
builder.Services.AddTransient<IVehicleService, VehicleService>();

builder.Services.AddMapster();
// Configure database
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection") ?? "Data Source=.;Database=CallTaxiDb;User Id=your_user;Password=your_password;TrustServerCertificate=True;Trusted_Connection=True;";
builder.Services.AddDatabaseServices(connectionString);

builder.Services.AddAuthentication("BasicAuthentication")
    .AddScheme<AuthenticationSchemeOptions, BasicAuthenticationHandler>("BasicAuthentication", null);


builder.Services.AddControllers(x =>
    {
        x.Filters.Add<ExceptionFilter>();
    }
);

// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.AddSecurityDefinition("BasicAuthentication", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "basic",
        In = ParameterLocation.Header,
        Description = "Basic Authorization header using the Bearer scheme."
    });
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme { Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "BasicAuthentication" } },
            new string[] { }
        }
    });
});


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
