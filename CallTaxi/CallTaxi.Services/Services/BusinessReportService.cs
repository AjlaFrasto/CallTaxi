using System.Linq;
using System.Threading.Tasks;
using CallTaxi.Model.Responses;
using CallTaxi.Services.Database;
using CallTaxi.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace CallTaxi.Services.Services
{
    public class BusinessReportService : IBusinessReportService
    {
        private readonly CallTaxiDbContext _context;
        public BusinessReportService(CallTaxiDbContext context)
        {
            _context = context;
        }

        public async Task<BusinessReportResponse> GetBusinessReportAsync()
        {
            // Driver with highest average review
            var driverWithHighestReviewsData = await _context.Users
                .Include(u => u.Gender)
                .Include(u => u.City)
                .Include(u => u.UserRoles).ThenInclude(ur => ur.Role)
                .Where(u => u.UserRoles.Any(ur => ur.Role.Name == "Driver"))
                .Select(u => new
                {
                    User = u,
                    AvgRating = _context.Reviews
                        .Where(r => r.DriveRequest.DriverId == u.Id)
                        .Average(r => (double?)r.Rating) ?? 0
                })
                .OrderByDescending(x => x.AvgRating)
                .FirstOrDefaultAsync();
            var driverWithHighestReviews = driverWithHighestReviewsData?.User;
            var bestDriverAverageRating = driverWithHighestReviewsData?.AvgRating;

            // User with most drives (only regular users, roleId 3)
            var userWithMostDrivesData = await _context.Users
                .Include(u => u.Gender)
                .Include(u => u.City)
                .Include(u => u.UserRoles).ThenInclude(ur => ur.Role)
                .Where(u => u.UserRoles.Any(ur => ur.RoleId == 3))
                .Select(u => new
                {
                    User = u,
                    DriveCount = _context.DriveRequests.Count(dr => dr.UserId == u.Id)
                })
                .OrderByDescending(x => x.DriveCount)
                .FirstOrDefaultAsync();
            var userWithMostDrives = userWithMostDrivesData?.User;
            var userWithMostDrivesCount = userWithMostDrivesData?.DriveCount;

            // Driver with most drives (only drivers, roleId 2)
            var driverWithMostDrivesData = await _context.Users
                .Include(u => u.Gender)
                .Include(u => u.City)
                .Include(u => u.UserRoles).ThenInclude(ur => ur.Role)
                .Where(u => u.UserRoles.Any(ur => ur.RoleId == 2))
                .Select(u => new
                {
                    User = u,
                    DriveCount = _context.DriveRequests.Count(dr => dr.DriverId == u.Id)
                })
                .OrderByDescending(x => x.DriveCount)
                .FirstOrDefaultAsync();
            var driverWithMostDrives = driverWithMostDrivesData?.User;
            var driverWithMostDrivesCount = driverWithMostDrivesData?.DriveCount;

            // Total money generated
            var totalMoneyGenerated = await _context.DriveRequests.SumAsync(dr => dr.FinalPrice);

            // City with most users
            var cityWithMostUsersData = await _context.Cities
               .Select(c => new
               {
                   City = c,
                   UserCount = _context.Users.Count(u =>
                       u.CityId == c.Id &&
                       u.UserRoles.Any(ur => ur.Role.Name == "User"))
               })
               .OrderByDescending(x => x.UserCount)
               .FirstOrDefaultAsync();
            var cityWithMostUsers = cityWithMostUsersData?.City;
            var cityWithMostUsersCount = cityWithMostUsersData?.UserCount;

            // City with most drivers
            var cityWithMostDriversData = await _context.Cities
                .Select(c => new
                {
                    City = c,
                    DriverCount = _context.Users.Count(u => u.CityId == c.Id && u.UserRoles.Any(ur => ur.Role.Name == "Driver"))
                })
                .OrderByDescending(x => x.DriverCount)
                .FirstOrDefaultAsync();
            var cityWithMostDrivers = cityWithMostDriversData?.City;
            var cityWithMostDriversCount = cityWithMostDriversData?.DriverCount;

            // Brand with most vehicles
            var brandWithMostVehiclesData = await _context.Brands
                .Select(b => new
                {
                    Brand = b,
                    VehicleCount = _context.Vehicles.Count(v => v.BrandId == b.Id)
                })
                .OrderByDescending(x => x.VehicleCount)
                .FirstOrDefaultAsync();
            var brandWithMostVehicles = brandWithMostVehiclesData?.Brand;
            var brandWithMostVehiclesCount = brandWithMostVehiclesData?.VehicleCount;

            return new BusinessReportResponse
            {
                DriverWithHighestReviews = driverWithHighestReviews != null ? new UserResponse
                {
                    Id = driverWithHighestReviews.Id,
                    FirstName = driverWithHighestReviews.FirstName,
                    LastName = driverWithHighestReviews.LastName,
                    Email = driverWithHighestReviews.Email,
                    Username = driverWithHighestReviews.Username,
                    Picture = driverWithHighestReviews.Picture,
                    IsActive = driverWithHighestReviews.IsActive,
                    CreatedAt = driverWithHighestReviews.CreatedAt,
                    LastLoginAt = driverWithHighestReviews.LastLoginAt,
                    PhoneNumber = driverWithHighestReviews.PhoneNumber,
                    GenderId = driverWithHighestReviews.GenderId,
                    GenderName = driverWithHighestReviews.Gender.Name,
                    CityId = driverWithHighestReviews.CityId,
                    CityName = driverWithHighestReviews.City.Name
                } : null,
                BestDriverAverageRating = bestDriverAverageRating,
                UserWithMostDrives = userWithMostDrives != null ? new UserResponse
                {
                    Id = userWithMostDrives.Id,
                    FirstName = userWithMostDrives.FirstName,
                    LastName = userWithMostDrives.LastName,
                    Email = userWithMostDrives.Email,
                    Username = userWithMostDrives.Username,
                    Picture = userWithMostDrives.Picture,
                    IsActive = userWithMostDrives.IsActive,
                    CreatedAt = userWithMostDrives.CreatedAt,
                    LastLoginAt = userWithMostDrives.LastLoginAt,
                    PhoneNumber = userWithMostDrives.PhoneNumber,
                    GenderId = userWithMostDrives.GenderId,
                    GenderName = userWithMostDrives.Gender.Name,
                    CityId = userWithMostDrives.CityId,
                    CityName = userWithMostDrives.City.Name
                } : null,
                UserWithMostDrivesCount = userWithMostDrivesCount,
                DriverWithMostDrives = driverWithMostDrives != null ? new UserResponse
                {
                    Id = driverWithMostDrives.Id,
                    FirstName = driverWithMostDrives.FirstName,
                    LastName = driverWithMostDrives.LastName,
                    Email = driverWithMostDrives.Email,
                    Username = driverWithMostDrives.Username,
                    Picture = driverWithMostDrives.Picture,
                    IsActive = driverWithMostDrives.IsActive,
                    CreatedAt = driverWithMostDrives.CreatedAt,
                    LastLoginAt = driverWithMostDrives.LastLoginAt,
                    PhoneNumber = driverWithMostDrives.PhoneNumber,
                    GenderId = driverWithMostDrives.GenderId,
                    GenderName = driverWithMostDrives.Gender.Name,
                    CityId = driverWithMostDrives.CityId,
                    CityName = driverWithMostDrives.City.Name
                } : null,
                DriverWithMostDrivesCount = driverWithMostDrivesCount,
                TotalMoneyGenerated = totalMoneyGenerated,
                CityWithMostUsers = cityWithMostUsers != null ? new CityResponse
                {
                    Id = cityWithMostUsers.Id,
                    Name = cityWithMostUsers.Name
                } : null,
                CityWithMostUsersCount = cityWithMostUsersCount,
                CityWithMostDrivers = cityWithMostDrivers != null ? new CityResponse
                {
                    Id = cityWithMostDrivers.Id,
                    Name = cityWithMostDrivers.Name
                } : null,
                CityWithMostDriversCount = cityWithMostDriversCount,
                BrandWithMostVehicles = brandWithMostVehicles != null ? new BrandResponse
                {
                    Id = brandWithMostVehicles.Id,
                    Name = brandWithMostVehicles.Name,
                    Logo = brandWithMostVehicles.Logo
                } : null,
                BrandWithMostVehiclesCount = brandWithMostVehiclesCount
            };
        }
    }
} 