using CallTaxi.Model.Requests;
using CallTaxi.Model.Responses;
using CallTaxi.Model.SearchObjects;
using eCommerce.Model.SearchObjects;
using eCommerce.Services;
using eCommerce.Services.Database;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

namespace CallTaxi.Services
{
    public class VehicleTierService : BaseCRUDService<VehicleTierResponse, VehicleTierSearchObject, VehicleTier, VehicleTierUpsertRequest, VehicleTierUpsertRequest>, IVehicleTierService
    {
        public VehicleTierService(CallTaxiDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<VehicleTier> ApplyFilter(IQueryable<VehicleTier> query, VehicleTierSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(vt => vt.Name.Contains(search.Name));
            }

            return query;
        }
    }
} 