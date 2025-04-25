using eCommerce.Services.Database;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Threading.Tasks;
using eCommerce.Model.Responses;
using eCommerce.Model.Requests;
using eCommerce.Model.SearchObjects;
using System.Linq;
using System;
using MapsterMapper;
using eCommerce.Model;
using CallTaxi.Model.Responses;
using CallTaxi.Model.Requests;

namespace eCommerce.Services.ProductStateMachine
{
    public class PendingVehicleState : BaseVehicleState
    {
        public PendingVehicleState(IServiceProvider serviceProvider, CallTaxiDbContext context, IMapper mapper) : base(serviceProvider, context, mapper)
        {
        }

        public override async Task<VehicleResponse> UpdateAsync(int id, VehicleUpdateRequest request)
        {
            var entity = await _context.Vehicles.FindAsync(id);

            _mapper.Map(request, entity);

            await _context.SaveChangesAsync();

            return _mapper.Map<VehicleResponse>(entity);
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