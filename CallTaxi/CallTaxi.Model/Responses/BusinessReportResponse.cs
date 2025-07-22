using System;

namespace CallTaxi.Model.Responses
{
    public class BusinessReportResponse
    {
        public UserResponse DriverWithHighestReviews { get; set; }
        public double? BestDriverAverageRating { get; set; }
        public UserResponse UserWithMostDrives { get; set; }
        public int? UserWithMostDrivesCount { get; set; }

        public UserResponse DriverWithMostDrives { get; set; }
        public int? DriverWithMostDrivesCount { get; set; }

        public decimal TotalMoneyGenerated { get; set; }
        public CityResponse CityWithMostUsers { get; set; }
        public int? CityWithMostUsersCount { get; set; }
        public CityResponse CityWithMostDrivers { get; set; }
        public int? CityWithMostDriversCount { get; set; }
        public BrandResponse BrandWithMostVehicles { get; set; }
        public int? BrandWithMostVehiclesCount { get; set; }
    }
} 