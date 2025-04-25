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
using CallTaxi.Model.Requests;
using CallTaxi.Model.Responses;

namespace eCommerce.Services.ProductStateMachine
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