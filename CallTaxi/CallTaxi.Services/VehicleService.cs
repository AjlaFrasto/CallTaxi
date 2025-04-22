using CallTaxi.Model.Requests;
using CallTaxi.Model.Responses;
using CallTaxi.Model.SearchObjects;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using eCommerce.Services;
using eCommerce.Services.Database;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

namespace CallTaxi.Services
{
    public class VehicleService : BaseCRUDService<VehicleResponse, VehicleSearchObject, Vehicle, VehicleUpsertRequest, VehicleUpsertRequest>, IVehicleService
    {
        public VehicleService(CallTaxiDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override async Task<VehicleResponse> CreateAsync(VehicleUpsertRequest request)
        {
            // Validate foreign keys
            var brand = await _context.Set<Brand>().FindAsync(request.BrandId);
            if (brand == null)
                throw new InvalidOperationException($"Brand with ID {request.BrandId} does not exist.");

            var user = await _context.Set<User>().FindAsync(request.UserId);
            if (user == null)
                throw new InvalidOperationException($"User with ID {request.UserId} does not exist.");

            var vehicleTier = await _context.Set<VehicleTier>().FindAsync(request.VehicleTierId);
            if (vehicleTier == null)
                throw new InvalidOperationException($"Vehicle Tier with ID {request.VehicleTierId} does not exist.");

            return await base.CreateAsync(request);
        }

        //public override async Task<PagedResult<VehicleResponse>> GetAsync(VehicleSearchObject search)
        //{
        //    var query = _context.Set<Vehicle>().AsQueryable();
        //    query = ApplyFilter(query, search);

        //    var result = await GetAsync<VehicleResponse>(query, search);

        //    // Enrich responses with related data
        //    foreach (var vehicle in result.Items)
        //    {
        //        var brand = await _context.Set<Brand>().FindAsync(vehicle.BrandId);
        //        if (brand != null)
        //            vehicle.BrandName = brand.Name;

        //        var vehicleTier = await _context.Set<VehicleTier>().FindAsync(vehicle.VehicleTierId);
        //        if (vehicleTier != null)
        //            vehicle.VehicleTierName = vehicleTier.Name;
        //    }

        //    return result;
        //}

        protected override IQueryable<Vehicle> ApplyFilter(IQueryable<Vehicle> query, VehicleSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(v => v.Name.Contains(search.Name));
            }

            if (!string.IsNullOrEmpty(search.LicensePlate))
            {
                query = query.Where(v => v.LicensePlate.Contains(search.LicensePlate));
            }

            if (search.BrandId.HasValue)
            {
                query = query.Where(v => v.BrandId == search.BrandId);
            }

            if (search.UserId.HasValue)
            {
                query = query.Where(v => v.UserId == search.UserId);
            }

            if (search.VehicleTierId.HasValue)
            {
                query = query.Where(v => v.VehicleTierId == search.VehicleTierId);
            }

            if (search.PetFriendly.HasValue)
            {
                query = query.Where(v => v.PetFriendly == search.PetFriendly);
            }

            return query.Include(v => v.Brand).Include(v => v.VehicleTier);
        }
    }
} 