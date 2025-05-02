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
using CallTaxi.RabbitMQ;
using CallTaxi.RabbitMQ.Models;

namespace CallTaxi.Services.VehicleStateMachine
{
    public class InitialVehicleState : BaseVehicleState
    {
        public InitialVehicleState(IServiceProvider serviceProvider, CallTaxiDbContext context, IMapper mapper) : base(serviceProvider, context, mapper)
        {
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

            var bus = RabbitHutch.CreateBus("host=localhost");

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