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
using EasyNetQ;
using CallTaxi.Subscriber.Data;
using Microsoft.Extensions.Configuration;
using CallTaxi.Subscriber.Models;
using CallTaxi.Subscriber;

namespace CallTaxi.Services.VehicleStateMachine
{
    public class RejectedVehicleState : BaseVehicleState
    {
        private readonly IConfiguration _configuration;

        public RejectedVehicleState(IServiceProvider serviceProvider, CallTaxiDbContext context, IMapper mapper, IConfiguration configuration) 
            : base(serviceProvider, context, mapper)
        {
            _configuration = configuration;
        }

        public override async Task<VehicleResponse> UpdateAsync(int id, VehicleUpdateRequest request)
        {
            var entity = await _context.Vehicles
                .Include(v => v.Brand)
                .FirstOrDefaultAsync(v => v.Id == id);

            if (entity == null)
                throw new InvalidOperationException($"Vehicle with ID {id} not found");

            _mapper.Map(request, entity);

            entity.StateMachine = "Pending";

            await _context.SaveChangesAsync();

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

        public override async Task<bool> DeleteAsync(int id)
        {
            var entity = await _context.Vehicles.FindAsync(id);
            if (entity == null)
                return false;

            // Rejected vehicles can be directly deleted
            _context.Vehicles.Remove(entity);
            await _context.SaveChangesAsync();

            return true;
        }
    }
}