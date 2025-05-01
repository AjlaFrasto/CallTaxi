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
        public DriveRequestService(CallTaxiDbContext context, IMapper mapper) : base(context, mapper)
        {
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
                query = query.Where(dr => dr.Status == search.Status);
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
            entity.Status = "Pending";
        }

        public async Task<DriveRequestResponse> AcceptRequest(int id)
        {
            var request = await _context.DriveRequests.FindAsync(id);
            if (request == null)
            {
                throw new InvalidOperationException("Drive request not found.");
            }

            if (request.Status != "Pending")
            {
                throw new InvalidOperationException("Only pending requests can be accepted.");
            }

            request.Status = "Accepted";
            request.AcceptedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return _mapper.Map<DriveRequestResponse>(request);
        }

        public async Task<DriveRequestResponse> CompleteRequest(int id)
        {
            var request = await _context.DriveRequests.FindAsync(id);
            if (request == null)
            {
                throw new InvalidOperationException("Drive request not found.");
            }

            if (request.Status != "Accepted")
            {
                throw new InvalidOperationException("Only accepted requests can be completed.");
            }

            request.Status = "Completed";
            request.CompletedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return _mapper.Map<DriveRequestResponse>(request);
        }

        public async Task<DriveRequestResponse> CancelRequest(int id)
        {
            var request = await _context.DriveRequests.FindAsync(id);
            if (request == null)
            {
                throw new InvalidOperationException("Drive request not found.");
            }

            if (request.Status != "Pending")
            {
                throw new InvalidOperationException("Only pending requests can be cancelled.");
            }

            request.Status = "Cancelled";
            await _context.SaveChangesAsync();

            return _mapper.Map<DriveRequestResponse>(request);
        }
    }
} 