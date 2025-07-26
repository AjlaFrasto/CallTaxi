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
    public class ReviewService : BaseCRUDService<ReviewResponse, ReviewSearchObject, Review, ReviewUpsertRequest, ReviewUpsertRequest>, IReviewService
    {
        public ReviewService(CallTaxiDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Review> ApplyFilter(IQueryable<Review> query, ReviewSearchObject search)
        {
            if (search.DriveRequestId.HasValue)
            {
                query = query.Where(r => r.DriveRequestId == search.DriveRequestId.Value);
            }

            if (search.UserId.HasValue)
            {
                query = query.Where(r => r.UserId == search.UserId.Value);
            }

            if (search.DriverId.HasValue)
            {
                query = query.Where(r => r.DriveRequest.DriverId == search.DriverId.Value);
            }

            if (search.MinRating.HasValue)
            {
                query = query.Where(r => r.Rating >= search.MinRating.Value);
            }

            if (search.MaxRating.HasValue)
            {
                query = query.Where(r => r.Rating <= search.MaxRating.Value);
            }

            if (!string.IsNullOrEmpty(search.FTS))
            {
                var fts = search.FTS.ToLower();
                query = query.Where(r =>
                    (r.Comment != null && r.Comment.ToLower().Contains(fts)) ||
                    (r.User.FirstName + " " + r.User.LastName).ToLower().Contains(fts) ||
                    (r.DriveRequest.Driver != null && (r.DriveRequest.Driver.FirstName + " " + r.DriveRequest.Driver.LastName).ToLower().Contains(fts))
                );
            }

            return query
                .Include(r => r.User)
                .Include(r => r.DriveRequest)
                    .ThenInclude(dr => dr.Driver);
        }

        protected override ReviewResponse MapToResponse(Review entity)
        {
            var response = base.MapToResponse(entity);
            // UserFullName from Review.User
            response.UserFullName = entity.User != null ? $"{entity.User.FirstName} {entity.User.LastName}" : null;
            // UserPicture from Review.User
            response.UserPicture = entity.User?.Picture;

            // DriverFullName and DriverPicture from DriveRequest.Driver
            if (entity.DriveRequest != null && entity.DriveRequest.Driver != null)
            {
                response.DriverFullName = $"{entity.DriveRequest.Driver.FirstName} {entity.DriveRequest.Driver.LastName}";
                response.DriverPicture = entity.DriveRequest.Driver.Picture;
            }
            else
            {
                response.DriverFullName = null;
                response.DriverPicture = null;
            }
            // Map StartLocation and EndLocation from DriveRequest
            if (entity.DriveRequest != null)
            {
                response.StartLocation = entity.DriveRequest.StartLocation;
                response.EndLocation = entity.DriveRequest.EndLocation;
            }
            else
            {
                response.StartLocation = null;
                response.EndLocation = null;
            }
            return response;
        }

        protected override async Task BeforeInsert(Review entity, ReviewUpsertRequest request)
        {
            // Check if the drive request exists and is completed
            var driveRequest = await _context.DriveRequests
                .Include(dr => dr.Status)
                .FirstOrDefaultAsync(dr => dr.Id == request.DriveRequestId);

            if (driveRequest == null)
            {
                throw new InvalidOperationException("Drive request not found.");
            }

            if (driveRequest.Status.Name != "Completed")
            {
                throw new InvalidOperationException("Cannot review a ride that hasn't been completed.");
            }

            // Check if the user making the request is the same user who created the drive request
            if (driveRequest.UserId != request.UserId)
            {
                throw new InvalidOperationException("Only the user who created the drive request can review it.");
            }

            // Check if user has already reviewed this drive request
            if (await _context.Reviews.AnyAsync(r => r.DriveRequestId == request.DriveRequestId && r.UserId == request.UserId))
            {
                throw new InvalidOperationException("You have already reviewed this ride.");
            }
        }

        protected override async Task BeforeUpdate(Review entity, ReviewUpsertRequest request)
        {
            // Check if the drive request exists and is completed
            var driveRequest = await _context.DriveRequests
                .Include(dr => dr.Status)
                .FirstOrDefaultAsync(dr => dr.Id == request.DriveRequestId);

            if (driveRequest == null)
            {
                throw new InvalidOperationException("Drive request not found.");
            }

            if (driveRequest.Status.Name != "Completed")
            {
                throw new InvalidOperationException("Cannot review a ride that hasn't been completed.");
            }

            // Check if the user making the request is the same user who created the drive request
            if (driveRequest.UserId != request.UserId)
            {
                throw new InvalidOperationException("Only the user who created the drive request can review it.");
            }
        }
    }
} 