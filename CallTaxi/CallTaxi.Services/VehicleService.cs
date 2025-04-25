using CallTaxi.Model.Requests;
using CallTaxi.Model.Responses;
using CallTaxi.Model.SearchObjects;
using eCommerce.Model.Responses;
using eCommerce.Model.SearchObjects;
using eCommerce.Services;
using eCommerce.Services.Database;
using eCommerce.Services.ProductStateMachine;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

namespace CallTaxi.Services
{
    public class VehicleService : BaseCRUDService<VehicleResponse, VehicleSearchObject, Vehicle, VehicleInsertRequest, VehicleUpdateRequest>, IVehicleService
    {
        protected readonly BaseVehicleState _baseVehicleState;
        public VehicleService(CallTaxiDbContext context, IMapper mapper, BaseVehicleState baseVehicleState) : base(context, mapper)
        {
            _baseVehicleState = baseVehicleState;
        }


        public override async Task<VehicleResponse> CreateAsync(VehicleInsertRequest request)
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



            var baseState = _baseVehicleState.GetProductState("Initial");
            var result = await baseState.CreateAsync(request);

            return result;
            // return base.CreateAsync(request);
        }

        public override async Task<VehicleResponse?> UpdateAsync(int id, VehicleUpdateRequest request)
        {
            var entity = await _context.Vehicles.FindAsync(id);
            var baseState = _baseVehicleState.GetProductState(entity.StateMachine);
            return await baseState.UpdateAsync(id, request);
            // return base.UpdateAsync(id, request);
        }

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

        public async Task<VehicleResponse> AcceptAsync(int id)
        {
            var entity = await _context.Vehicles.FindAsync(id);
            var baseState = _baseVehicleState.GetProductState(entity.StateMachine);

            return await baseState.AcceptAsync(id);
        }

        public async Task<VehicleResponse> RejectAsync(int id)
        {
            var entity = await _context.Vehicles.FindAsync(id);
            var baseState = _baseVehicleState.GetProductState(entity.StateMachine);

            return await baseState.RejectAsync(id);
        }

        public override async Task<bool> DeleteAsync(int id)
        {
            var entity = await _context.Vehicles.FindAsync(id);
            if (entity == null)
                return false;

            var baseState = _baseVehicleState.GetProductState(entity.StateMachine);
            return await baseState.DeleteAsync(id);
        }

    }
} 