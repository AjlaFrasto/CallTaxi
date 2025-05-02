using System;
using System.Threading.Tasks;
using CallTaxi.Services.Database;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using CallTaxi.Model.Responses;
using CallTaxi.Model.Requests;
using CallTaxi.Model.SearchObjects;
using System.Linq;
using MapsterMapper;
using CallTaxi.Model;
using EasyNetQ;
using CallTaxi.Subscriber.Models;
using CallTaxi.Subscriber;

namespace CallTaxi.Services.VehicleStateMachine
{
    public class PendingVehicleState : BaseVehicleState
    {
        public PendingVehicleState(IServiceProvider serviceProvider, CallTaxiDbContext context, IMapper mapper) : base(serviceProvider, context, mapper)
        {
        }

        public override async Task<VehicleResponse> UpdateAsync(int id, VehicleUpdateRequest request)
        {
            var entity = await _context.Vehicles
                .Include(v => v.Brand)
                .FirstOrDefaultAsync(v => v.Id == id);

            if (entity == null)
                throw new InvalidOperationException($"Vehicle with ID {id} not found");

            _mapper.Map(request, entity);

            await _context.SaveChangesAsync();

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

        public override async Task<VehicleResponse> AcceptAsync(int id)
        {
            var entity = await _context.Vehicles.FindAsync(id);
            entity.StateMachine = "Accepted";

            await _context.SaveChangesAsync();

            return _mapper.Map<VehicleResponse>(entity);
        }

        public override async Task<VehicleResponse> RejectAsync(int id)
        {
            var entity = await _context.Vehicles.FindAsync(id);
            entity.StateMachine = "Rejected";

            await _context.SaveChangesAsync();

            return _mapper.Map<VehicleResponse>(entity);
        }

        public override async Task<bool> DeleteAsync(int id)
        {
            var entity = await _context.Vehicles.FindAsync(id);
            if (entity == null)
                return false;

            _context.Vehicles.Remove(entity);
            await _context.SaveChangesAsync();

            return true;
        }
    }
} 