using CallTaxi.Services.Database;
using Mapster;
using Microsoft.AspNetCore.Authentication;
using Microsoft.OpenApi.Models;
using CallTaxi.Services.VehicleStateMachine;
using CallTaxi.WebAPI.Filters;
using CallTaxi.Services.Services;
using CallTaxi.Services.Interfaces;
using System.Reflection;
using Microsoft.Extensions.Configuration;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddTransient<IUserService, UserService>();
builder.Services.AddTransient<IRoleService, RoleService>();
builder.Services.AddTransient<IGenderService, GenderService>();
builder.Services.AddTransient<ICityService, CityService>();
builder.Services.AddTransient<IChatService, ChatService>();

// State Machine
builder.Services.AddTransient<BaseVehicleState>();
builder.Services.AddTransient<InitialVehicleState>();
builder.Services.AddTransient<PendingVehicleState>();
builder.Services.AddTransient<AcceptedVehicleState>();
builder.Services.AddTransient<RejectedVehicleState>();

// Add new services
builder.Services.AddTransient<IBrandService, BrandService>();
builder.Services.AddTransient<IVehicleTierService, VehicleTierService>();
builder.Services.AddTransient<IVehicleService, VehicleService>();
builder.Services.AddTransient<IDriveRequestService, DriveRequestService>();
builder.Services.AddTransient<IDriveRequestStatusService, DriveRequestStatusService>();
builder.Services.AddTransient<IReviewService, ReviewService>();

// Configure database
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection") ?? "Data Source=.;Database=CallTaxiDb;User Id=sa;Password=QWEasd123!;TrustServerCertificate=True;Trusted_Connection=True;";
builder.Services.AddDatabaseServices(connectionString);

// Add configuration
builder.Services.AddSingleton<IConfiguration>(builder.Configuration);

builder.Services.AddMapster();

builder.Services.AddAuthentication("BasicAuthentication")
    .AddScheme<AuthenticationSchemeOptions, BasicAuthenticationHandler>("BasicAuthentication", null);

builder.Services.AddControllers(x =>
    {
        x.Filters.Add<ExceptionFilter>();
    }
);

// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();

// Za dodavanje opisnog teksta pored swagger call-a
var xmlFilename = $"{Assembly.GetExecutingAssembly().GetName().Name}.xml";

builder.Services.AddSwaggerGen(c =>
{
    c.IncludeXmlComments(Path.Combine(AppContext.BaseDirectory, xmlFilename));

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

// Configure the HTTP request pipeline.
//if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

using (var scope = app.Services.CreateScope())
{
    var dataContext = scope.ServiceProvider.GetRequiredService<CallTaxiDbContext>();


    var pendingMigrations = dataContext.Database.GetPendingMigrations().Any();

    if (pendingMigrations)
    {

        dataContext.Database.Migrate();


    }
}

app.Run();
