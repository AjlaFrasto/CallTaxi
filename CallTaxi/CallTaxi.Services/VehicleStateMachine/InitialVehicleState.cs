using CallTaxi.Services.Database;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Threading.Tasks;
using CallTaxi.Model.Responses;
using CallTaxi.Model.Requests;
using CallTaxi.Model.SearchObjects;
using System.Linq;
using System;
using MapsterMapper;
using CallTaxi.Model;
using EasyNetQ;
using CallTaxi.Subscriber.Models;
using Microsoft.Extensions.Configuration;
using CallTaxi.Subscriber;

namespace CallTaxi.Services.VehicleStateMachine
{
    public class InitialVehicleState : BaseVehicleState
    {
        private readonly IConfiguration _configuration;

        public InitialVehicleState(IServiceProvider serviceProvider, CallTaxiDbContext context, IMapper mapper, IConfiguration configuration) 
            : base(serviceProvider, context, mapper)
        {
            _configuration = configuration;
        }

        public override async Task<VehicleResponse> CreateAsync(VehicleInsertRequest request)
        {
            var entity = new Database.Vehicle();
            _mapper.Map(request, entity);

            entity.StateMachine = "Pending";

            _context.Vehicles.Add(entity);
            await _context.SaveChangesAsync();

            // Reload entity with Brand information
            await _context.Entry(entity).Reference(v => v.Brand).LoadAsync();

            // Get admin emails
            var adminEmails = await _context.Users
                .Where(u => u.UserRoles.Any(ur => ur.Role.Name == "Administrator"))
                .Select(u => u.Email)
                .ToListAsync();

            var host = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "localhost";
            var username = Environment.GetEnvironmentVariable("RABBITMQ_USERNAME") ?? "guest";
            var password = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD") ?? "guest";
            var virtualhost = Environment.GetEnvironmentVariable("RABBITMQ_VIRTUALHOST") ?? "/";
            var bus = RabbitHutch.CreateBus($"host={host};virtualHost={virtualhost};username={username};password={password}");

            var response = _mapper.Map<VehicleResponse>(entity);
            response.BrandLogo = entity.Brand?.Logo;

            // Create RabbitMQ notification DTO
            var notificationDto = new VehicleNotificationDto
            {
                BrandName = entity.Brand.Name,
                Name = entity.Name,
                AdminEmails = adminEmails
            };

            var vehicleNotification = new VehicleNotification
            {
                Vehicle = notificationDto
            };
            await bus.PubSub.PublishAsync(vehicleNotification);

            return response;
        }
    }
} 