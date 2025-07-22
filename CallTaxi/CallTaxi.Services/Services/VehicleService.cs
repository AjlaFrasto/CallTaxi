using CallTaxi.Model.Requests;
using CallTaxi.Model.Responses;
using CallTaxi.Model.SearchObjects;
using CallTaxi.Services.Database;
using CallTaxi.Services.Interfaces;
using CallTaxi.Services.VehicleStateMachine;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

namespace CallTaxi.Services.Services
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
            if (!string.IsNullOrEmpty(search.FTS))
            {
                var fts = search.FTS.ToLower();
                query = query.Where(v =>
                    v.Name.ToLower().Contains(fts) ||
                    v.Brand.Name.ToLower().Contains(fts) ||
                    (v.User.FirstName + " " + v.User.LastName).ToLower().Contains(fts) ||
                    (v.Brand.Name + " " + v.Name).ToLower().Contains(fts)
                );
            }

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

            if (!string.IsNullOrEmpty(search.BrandName))
            {
                query = query.Where(v => v.Brand.Name.Contains(search.BrandName));
            }

            if (search.UserId.HasValue)
            {
                query = query.Where(v => v.UserId == search.UserId);
            }

            if (!string.IsNullOrEmpty(search.UserFullName))
            {
                query = query.Where(v => (v.User.FirstName + " " + v.User.LastName).Contains(search.UserFullName));
            }

            if (search.VehicleTierId.HasValue)
            {
                query = query.Where(v => v.VehicleTierId == search.VehicleTierId);
            }

            if (search.PetFriendly.HasValue)
            {
                query = query.Where(v => v.PetFriendly == search.PetFriendly);
            }

            // Ensure User is included for UserFullName
            return query.Include(v => v.Brand).Include(v => v.VehicleTier).Include(v => v.User);
        }

        protected override VehicleResponse MapToResponse(Vehicle entity)
        {
            var response = base.MapToResponse(entity);
            response.BrandLogo = entity.Brand?.Logo;
            response.UserFullName = entity.User != null ? $"{entity.User.FirstName} {entity.User.LastName}" : string.Empty;
            response.VehicleTierName = entity.VehicleTier?.Name;
            return response;
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