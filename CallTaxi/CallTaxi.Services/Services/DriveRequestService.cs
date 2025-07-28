using CallTaxi.Model.Requests;
using CallTaxi.Model.Responses;
using CallTaxi.Model.SearchObjects;
using CallTaxi.Services.Database;
using CallTaxi.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace CallTaxi.Services.Services
{
    public class DriveRequestService : BaseCRUDService<DriveRequestResponse, DriveRequestSearchObject, DriveRequest, DriveRequestUpsertRequest, DriveRequestUpsertRequest>, IDriveRequestService
    {
        private const int STATUS_PENDING = 1;
        private const int STATUS_ACCEPTED = 2;
        private const int STATUS_COMPLETED = 3;
        private const int STATUS_CANCELLED = 4;
        private const int STATUS_PAID = 5;

        public DriveRequestService(CallTaxiDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override async Task<PagedResult<DriveRequestResponse>> GetAsync(DriveRequestSearchObject search)
        {
            var query = _context.DriveRequests
                .Include(x => x.User)
                .Include(x => x.VehicleTier)
                .Include(x => x.Status)
                .Include(x => x.Vehicle!.Brand)
                .AsQueryable();

            query = ApplyFilter(query, search);

            int? totalCount = null;
            if (search.IncludeTotalCount)
            {
                totalCount = await query.CountAsync();
            }

            if (!search.RetrieveAll)
            {
                if (search.Page.HasValue)
                {
                    query = query.Skip(search.Page.Value * search.PageSize.Value);
                }
                if (search.PageSize.HasValue)
                {
                    query = query.Take(search.PageSize.Value);
                }
            }

            var list = await query.ToListAsync();

            var result = new PagedResult<DriveRequestResponse>
            {
                Items = list.Select(x => MapToResponse(x)).ToList(),
                TotalCount = totalCount
            };

            return result;
        }

        public override async Task<DriveRequestResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.DriveRequests
                .Include(x => x.User)
                .Include(x => x.VehicleTier)
                .Include(x => x.Status)
                .FirstOrDefaultAsync(x => x.Id == id);

            if (entity == null)
                return null;

            return MapToResponse(entity);
        }

        protected override DriveRequestResponse MapToResponse(DriveRequest entity)
        {
            var response = base.MapToResponse(entity);
            
            if (entity.User != null)
            {
                response.UserFullName = $"{entity.User.FirstName} {entity.User.LastName}";
            }
            
            if (entity.VehicleTier != null)
            {
                response.VehicleTierName = entity.VehicleTier.Name;
            }

            if (entity.Status != null)
            {
                response.StatusName = entity.Status.Name;
            }

            // Map driver information if available
            if (entity.Driver != null)
            {
                response.DriverId = entity.DriverId;
                response.DriverFullName = $"{entity.Driver.FirstName} {entity.Driver.LastName}";
            }

            // Map vehicle information if available
            if (entity.Vehicle != null)
            {
                response.VehicleId = entity.VehicleId;
                response.VehicleName = entity.Vehicle.Brand != null ? ($"{entity.Vehicle.Brand.Name} {entity.Vehicle.Name}") : entity.Vehicle.Name;
                response.VehicleLicensePlate = entity.Vehicle.LicensePlate;
            }

            return response;
        }

        protected override IQueryable<DriveRequest> ApplyFilter(IQueryable<DriveRequest> query, DriveRequestSearchObject search = null)
        {
            query = query
                .Include(x => x.User)
                .Include(x => x.Driver)
                .Include(x => x.Vehicle)
                .Include(x => x.VehicleTier)
                .Include(x => x.Status);

            if (search != null)
            {
                if (!string.IsNullOrEmpty(search.FTS))
                {
                    var fts = search.FTS.ToLower();
                    query = query.Where(x =>
                        (x.User.FirstName + " " + x.User.LastName).ToLower().Contains(fts) ||
                        (x.Driver != null && (x.Driver.FirstName + " " + x.Driver.LastName).ToLower().Contains(fts)) ||
                        (x.Vehicle != null && x.Vehicle.Brand != null && (x.Vehicle.Brand.Name + " " + x.Vehicle.Name).ToLower().Contains(fts))
                    );
                }

                if (search.UserId.HasValue)
                    query = query.Where(x => x.UserId == search.UserId);

                if (search.DriverId.HasValue)
                    query = query.Where(x => x.DriverId == search.DriverId);

                if (search.VehicleTierId.HasValue)
                    query = query.Where(x => x.VehicleTierId == search.VehicleTierId);

                if (!string.IsNullOrWhiteSpace(search.Status))
                {
                    query = query.Where(x => x.Status.Name == search.Status);
                }

                if (search.CreatedFrom.HasValue)
                    query = query.Where(x => x.CreatedAt >= search.CreatedFrom.Value);

                if (search.CreatedTo.HasValue)
                    query = query.Where(x => x.CreatedAt <= search.CreatedTo.Value);
            }

            return base.ApplyFilter(query, search);
        }

        protected override async Task BeforeInsert(DriveRequest entity, DriveRequestUpsertRequest request)
        {
            // Calculate final price based on vehicle tier
            var vehicleTier = await _context.VehicleTiers.FindAsync(request.VehicleTierId);
            if (vehicleTier == null)
            {
                throw new InvalidOperationException("Invalid vehicle tier selected.");
            }

            decimal priceMultiplier = vehicleTier.Name switch
            {
                "Standard" => 1.0m,
                "Premium" => 1.25m,
                "Luxury" => 1.5m,
                _ => 1.0m
            };

            entity.FinalPrice = request.BasePrice * priceMultiplier;
            entity.StatusId = STATUS_PENDING;
        }

        public async Task<DriveRequestResponse> AcceptRequest(int id, int driverId, int vehicleId)
        {
            var request = await _context.DriveRequests
                .Include(dr => dr.VehicleTier)
                .FirstOrDefaultAsync(dr => dr.Id == id);

            if (request == null)
                throw new Exception("Drive request not found");

            var pendingStatus = await _context.DriveRequestStatuses
                .FirstOrDefaultAsync(s => s.Name == "Pending");

            if (request.StatusId != pendingStatus?.Id)
                throw new Exception("Cannot accept a request that is not in pending state");

            // Validate that the driver exists and has the Driver role
            var driver = await _context.Users
                .Include(u => u.UserRoles)
                .ThenInclude(ur => ur.Role)
                .FirstOrDefaultAsync(u => u.Id == driverId && 
                                        u.UserRoles.Any(ur => ur.Role.Name == "Driver"));

            if (driver == null)
                throw new Exception("Driver not found or user is not a driver");

            // Validate that the vehicle exists, belongs to the driver, and matches the required tier
            var vehicle = await _context.Vehicles
                .FirstOrDefaultAsync(v => v.Id == vehicleId);

            if (vehicle == null)
                throw new Exception("Vehicle not found");

            if (vehicle.UserId != driverId)
                throw new Exception("Vehicle does not belong to the specified driver");

            if (vehicle.VehicleTierId != request.VehicleTierId)
                throw new Exception("Vehicle tier does not match the request requirements");

            // Update request status
            var acceptedStatus = await _context.DriveRequestStatuses
                .FirstOrDefaultAsync(s => s.Name == "Accepted");

            if (acceptedStatus == null)
                throw new Exception("Accepted status not found");

            request.StatusId = acceptedStatus.Id;
            request.DriverId = driverId;
            request.VehicleId = vehicleId;
            request.AcceptedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            return MapToResponse(request);
        }

        public async Task<DriveRequestResponse> CompleteRequest(int id)
        {
            var request = await _context.DriveRequests
                .FirstOrDefaultAsync(dr => dr.Id == id);

            if (request == null)
                throw new Exception("Drive request not found");

            var paidStatus = await _context.DriveRequestStatuses
                .FirstOrDefaultAsync(s => s.Name == "Paid");

            if (request.StatusId != paidStatus?.Id)
                throw new Exception("Cannot complete a request that is not in paid state");

            var completedStatus = await _context.DriveRequestStatuses
                .FirstOrDefaultAsync(s => s.Name == "Completed");

            if (completedStatus == null)
                throw new Exception("Completed status not found");

            request.StatusId = completedStatus.Id;
            request.CompletedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            return MapToResponse(request);
        }

        public async Task<DriveRequestResponse> CancelRequest(int id)
        {
            var request = await _context.DriveRequests
                .FirstOrDefaultAsync(dr => dr.Id == id);

            if (request == null)
                throw new Exception("Drive request not found");

            var pendingStatus = await _context.DriveRequestStatuses
                .FirstOrDefaultAsync(s => s.Name == "Pending");

            if (request.StatusId != pendingStatus?.Id)
                throw new Exception("Can only cancel pending requests");

            var cancelledStatus = await _context.DriveRequestStatuses
                .FirstOrDefaultAsync(s => s.Name == "Cancelled");

            if (cancelledStatus == null)
                throw new Exception("Cancelled status not found");

            request.StatusId = cancelledStatus.Id;

            await _context.SaveChangesAsync();

            return MapToResponse(request);
        }

        public async Task<DriveRequestResponse> MarkAsPaid(int id)
        {
            var request = await _context.DriveRequests
                .FirstOrDefaultAsync(dr => dr.Id == id);

            if (request == null)
                throw new Exception("Drive request not found");

            var acceptedStatus = await _context.DriveRequestStatuses
                .FirstOrDefaultAsync(s => s.Name == "Accepted");

            if (request.StatusId != acceptedStatus?.Id)
                throw new Exception("Can only mark accepted requests as paid");

            var paidStatus = await _context.DriveRequestStatuses
                .FirstOrDefaultAsync(s => s.Name == "Paid");

            if (paidStatus == null)
                throw new Exception("Paid status not found");

            request.StatusId = paidStatus.Id;

            await _context.SaveChangesAsync();

            return MapToResponse(request);
        }
    }
} 