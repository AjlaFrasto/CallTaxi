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

            return _mapper.Map<VehicleResponse>(entity);
        }
    }
} 