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
    public class DraftVehicleState : BaseVehicleState
    {
        public DraftVehicleState(IServiceProvider serviceProvider, CallTaxiDbContext context, IMapper mapper) : base(serviceProvider, context, mapper)
        {
        }

        public override async Task<VehicleResponse> UpdateAsync(int id, VehicleUpdateRequest request)
        {
            var entity = await _context.Products.FindAsync(id);

            _mapper.Map(request, entity);

            await _context.SaveChangesAsync();

            return _mapper.Map<VehicleResponse>(entity);
        }

        //public override async Task<ProductResponse> ActivateAsync(int id)
        //{
        //    var entity = await _context.Products.FindAsync(id);
        //    entity.ProductState = nameof(ActiveProductState);

        //    await _context.SaveChangesAsync();

        //    return _mapper.Map<ProductResponse>(entity);
        //}

        //public override async Task<ProductResponse> DeactivateAsync(int id)
        //{
        //    var entity = await _context.Products.FindAsync(id);
        //    entity.ProductState = nameof(DeactivatedProductState);
        //    entity.Name = entity.Name + "Deactivated from draft";

        //    await _context.SaveChangesAsync();

        //    return _mapper.Map<ProductResponse>(entity);
        //}
    }
} 