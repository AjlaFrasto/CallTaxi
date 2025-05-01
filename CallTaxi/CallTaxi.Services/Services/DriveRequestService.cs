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

        public DriveRequestService(CallTaxiDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override async Task<PagedResult<DriveRequestResponse>> GetAsync(DriveRequestSearchObject search)
        {
            var query = _context.DriveRequests
                .Include(x => x.User)
                .Include(x => x.VehicleTier)
                .Include(x => x.Status)
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
                response.UserName = $"{entity.User.FirstName} {entity.User.LastName}";
            }
            
            if (entity.VehicleTier != null)
            {
                response.VehicleTierName = entity.VehicleTier.Name;
            }

            if (entity.Status != null)
            {
                response.StatusName = entity.Status.Name;
            }

            return response;
        }

        protected override IQueryable<DriveRequest> ApplyFilter(IQueryable<DriveRequest> query, DriveRequestSearchObject search)
        {
            if (search.UserId.HasValue)
            {
                query = query.Where(dr => dr.UserId == search.UserId.Value);
            }

            if (search.VehicleTierId.HasValue)
            {
                query = query.Where(dr => dr.VehicleTierId == search.VehicleTierId.Value);
            }

            if (!string.IsNullOrEmpty(search.Status))
            {
                query = query.Where(dr => dr.Status.Name == search.Status);
            }

            if (search.CreatedFrom.HasValue)
            {
                query = query.Where(dr => dr.CreatedAt >= search.CreatedFrom.Value);
            }

            if (search.CreatedTo.HasValue)
            {
                query = query.Where(dr => dr.CreatedAt <= search.CreatedTo.Value);
            }

            return query;
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

        public async Task<DriveRequestResponse> AcceptRequest(int id)
        {
            var request = await _context.DriveRequests
                .Include(x => x.User)
                .Include(x => x.VehicleTier)
                .Include(x => x.Status)
                .FirstOrDefaultAsync(x => x.Id == id);

            if (request == null)
            {
                throw new InvalidOperationException("Drive request not found.");
            }

            if (request.StatusId != STATUS_PENDING)
            {
                throw new InvalidOperationException("Only pending requests can be accepted.");
            }

            request.StatusId = STATUS_ACCEPTED;
            request.AcceptedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return MapToResponse(request);
        }

        public async Task<DriveRequestResponse> CompleteRequest(int id)
        {
            var request = await _context.DriveRequests
                .Include(x => x.User)
                .Include(x => x.VehicleTier)
                .Include(x => x.Status)
                .FirstOrDefaultAsync(x => x.Id == id);

            if (request == null)
            {
                throw new InvalidOperationException("Drive request not found.");
            }

            if (request.StatusId != STATUS_ACCEPTED)
            {
                throw new InvalidOperationException("Only accepted requests can be completed.");
            }

            request.StatusId = STATUS_COMPLETED;
            request.CompletedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return MapToResponse(request);
        }

        public async Task<DriveRequestResponse> CancelRequest(int id)
        {
            var request = await _context.DriveRequests
                .Include(x => x.User)
                .Include(x => x.VehicleTier)
                .Include(x => x.Status)
                .FirstOrDefaultAsync(x => x.Id == id);

            if (request == null)
            {
                throw new InvalidOperationException("Drive request not found.");
            }

            if (request.StatusId != STATUS_PENDING)
            {
                throw new InvalidOperationException("Only pending requests can be cancelled.");
            }

            request.StatusId = STATUS_CANCELLED;
            await _context.SaveChangesAsync();

            return MapToResponse(request);
        }
    }
} 