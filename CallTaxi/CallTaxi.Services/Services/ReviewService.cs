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
                query = query.Where(r => r.Comment != null && r.Comment.Contains(search.FTS));
            }

            return query;
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