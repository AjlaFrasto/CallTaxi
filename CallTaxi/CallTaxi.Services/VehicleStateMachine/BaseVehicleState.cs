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
using Microsoft.Extensions.DependencyInjection;
using CallTaxi.Model.Responses;
using CallTaxi.Model.Requests;

namespace eCommerce.Services.ProductStateMachine
{
   public class BaseVehicleState
   {
        protected readonly IServiceProvider _serviceProvider;
        protected readonly CallTaxiDbContext _context;
        protected readonly IMapper _mapper;

        public BaseVehicleState(IServiceProvider serviceProvider, CallTaxiDbContext context, IMapper mapper) {
            _serviceProvider = serviceProvider;
            _context = context;
            _mapper = mapper;

        }
        public virtual async Task<VehicleResponse> CreateAsync(VehicleInsertRequest request)
        {
                throw new UserException("Not allowed in current state");
        }

        public virtual async Task<VehicleResponse> UpdateAsync(int id, VehicleUpdateRequest request)
        {
                throw new UserException("Not allowed in current state");
        }
        
        public virtual async Task<VehicleResponse> AcceptAsync(int id)
        {
                throw new UserException("Not allowed in current state");
        }

        public virtual async Task<VehicleResponse> RejectAsync(int id)
        {
                throw new UserException("Not allowed in current state");
        }

        public BaseVehicleState GetProductState(string stateName) {
            switch (stateName)
            {
                case "Initial":
                    return _serviceProvider.GetService<InitialVehicleState>();
                case "Draft":
                    return _serviceProvider.GetService<DraftVehicleState>();
                //case nameof(ActiveProductState):
                //    return _serviceProvider.GetService<ActiveProductState>();
                //case nameof(DeactivatedProductState):
                //    return _serviceProvider.GetService<DeactivatedProductState>();   

                default:
                    throw new Exception($"State {stateName} not defined");
            }
        }
   }
} 