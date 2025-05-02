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

            var rabbitConfig = _configuration.GetSection("RabbitMQ");
            var connectionString = $"host={rabbitConfig["HostName"]};username={rabbitConfig["UserName"]};password={rabbitConfig["Password"]}";
            var bus = RabbitHutch.CreateBus(connectionString);

            var response = _mapper.Map<VehicleResponse>(entity);

            // Create RabbitMQ notification DTO
            var notificationDto = new VehicleNotificationDto
            {
                BrandName = entity.Brand.Name,
                Name = entity.Name
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