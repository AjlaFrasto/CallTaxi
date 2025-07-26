using CallTaxi.Services.Helpers;
using Microsoft.EntityFrameworkCore;
using System;

namespace CallTaxi.Services.Database
{
    public static class ModelBuilderExtensions
    {
        private const string DefaultPhoneNumber = "+387 62 667 961";
        
        private const string TestMailSender = "calltaxi.sender@gmail.com";
        private const string TestMailReceiver = "calltaxi.receiver@gmail.com";

        public static void SeedData(this ModelBuilder modelBuilder)
        {
            // Use a fixed date for all timestamps
            var fixedDate = new DateTime(2024, 1, 1, 0, 0, 0, DateTimeKind.Utc);

            // Seed Roles
            modelBuilder.Entity<Role>().HasData(
                new Role 
                { 
                    Id = 1, 
                    Name = "Administrator", 
                    Description = "System administrator with full access", 
                    CreatedAt = fixedDate, 
                    IsActive = true 
                },
                new Role 
                { 
                    Id = 2, 
                    Name = "Driver", 
                    Description = "Taxi driver role", 
                    CreatedAt = fixedDate, 
                    IsActive = true 
                },
                new Role 
                { 
                    Id = 3, 
                    Name = "User", 
                    Description = "Regular user role", 
                    CreatedAt = fixedDate, 
                    IsActive = true 
                }
            );

            // Seed Users
            modelBuilder.Entity<User>().HasData(
                new User 
                { 
                    Id = 1, 
                    FirstName = "Denis", 
                    LastName = "Mušić", 
                    Email = TestMailReceiver, 
                    Username = "admin", 
                    PasswordHash = "3KbrBi5n9zdQnceWWOK5zaeAwfEjsluyhRQUbNkcgLQ=", 
                    PasswordSalt = "6raKZCuEsvnBBxPKHGpRtA==", 
                    IsActive = true, 
                    CreatedAt = fixedDate,
                    PhoneNumber = DefaultPhoneNumber,
                    GenderId = 1, // Male
                    CityId = 5, // Sarajevo
                    Picture = ImageConversion.ConvertImageToByteArray("Assets", "10.png")
                },
                new User 
                { 
                    Id = 2, 
                    FirstName = "Amel", 
                    LastName = "Musić",
                    Email = "example1@gmail.com",
                    Username = "driver", 
                    PasswordHash = "kDPVcZaikiII7vXJbMEw6B0xZ245I29ocaxBjLaoAC0=", 
                    PasswordSalt = "O5R9WmM6IPCCMci/BCG/eg==", 
                    IsActive = true, 
                    CreatedAt = fixedDate,
                    PhoneNumber = DefaultPhoneNumber,
                    GenderId = 1, // Male
                    CityId = 5, // Banja Luka
                    Picture = ImageConversion.ConvertImageToByteArray("Assets", "11.png")
                },
                new User 
                { 
                    Id = 3, 
                    FirstName = "Adil", 
                    LastName = "Joldić",
                    Email = "example2@gmail.com",
                    Username = "driver2", 
                    PasswordHash = "BiWDuil9svAKOYzii5wopQW3YqjVfQrzGE2iwH/ylY4=", 
                    PasswordSalt = "pfNS+OLBaQeGqBIzXXcWuA==", 
                    IsActive = true, 
                    CreatedAt = fixedDate,
                    PhoneNumber = DefaultPhoneNumber,
                    GenderId = 1, // Male
                    CityId = 5, // Tuzla
                    Picture = ImageConversion.ConvertImageToByteArray("Assets", "13.png")
                },
                new User 
                { 
                    Id = 4, 
                    FirstName = "Ajla", 
                    LastName = "Frašto", 
                    Email = TestMailSender, 
                    Username = "user", 
                    PasswordHash = "KUF0Jsocq9AqdwR9JnT2OrAqm5gDj7ecQvNwh6fW/Bs=", 
                    PasswordSalt = "c3ZKo0va3tYfnYuNKkHDbQ==", 
                    IsActive = true, 
                    CreatedAt = fixedDate,
                    PhoneNumber = DefaultPhoneNumber,
                    GenderId = 2, // Female
                    CityId = 1, // Zenica
                    Picture = ImageConversion.ConvertImageToByteArray("Assets", "14.png")
                },
                new User 
                { 
                    Id = 5, 
                    FirstName = "Elmir", 
                    LastName = "Babović", 
                    Email = "example3@gmail.com", 
                    Username = "user2", 
                    PasswordHash = "juUTOe91pl0wpxh00N7eCzScw63/1gzn5vrGMsRCAhY=", 
                    PasswordSalt = "4ayImwSF0Q1QlxPABDp9Mw==", 
                    IsActive = true, 
                    CreatedAt = fixedDate,
                    PhoneNumber = DefaultPhoneNumber,
                    GenderId = 1, // Male
                    CityId = 5, // Mostar
                    Picture = ImageConversion.ConvertImageToByteArray("Assets", "12.png")
                }
            );

            // Seed UserRoles
            modelBuilder.Entity<UserRole>().HasData(
                new UserRole 
                { 
                    Id = 1, 
                    UserId = 1, 
                    RoleId = 1, 
                    DateAssigned = fixedDate // Admin user with Administrator role
                },
                new UserRole 
                { 
                    Id = 2, 
                    UserId = 2, 
                    RoleId = 2, 
                    DateAssigned = fixedDate // Driver One with Driver role
                },
                new UserRole 
                { 
                    Id = 3, 
                    UserId = 3, 
                    RoleId = 2, 
                    DateAssigned = fixedDate // Driver Two with Driver role
                },
                new UserRole 
                { 
                    Id = 4, 
                    UserId = 4, 
                    RoleId = 3, 
                    DateAssigned = fixedDate // User One with User role
                },
                new UserRole 
                { 
                    Id = 5, 
                    UserId = 5, 
                    RoleId = 3, 
                    DateAssigned = fixedDate // User Two with User role
                }
            );

            // Seed Vehicle Tiers
            modelBuilder.Entity<VehicleTier>().HasData(
                new VehicleTier
                {
                    Id = 1,
                    Name = "Standard",
                    Description = "Basic vehicle tier for everyday rides."
                },
                new VehicleTier
                {
                    Id = 2,
                    Name = "Premium",
                    Description = "Comfortable rides with experienced drivers and newer vehicles."
                },
                new VehicleTier
                {
                    Id = 3,
                    Name = "Luxury",
                    Description = "High-end vehicles offering top-tier comfort and amenities."
                }
            );

            // Seed Brands
            modelBuilder.Entity<Brand>().HasData(
                new Brand { Id = 1, Name = "Mercedes-Benz", Logo = ImageConversion.ConvertImageToByteArray("Assets","1.png") },
                new Brand { Id = 2, Name = "BMW", Logo = ImageConversion.ConvertImageToByteArray("Assets", "2.png") },
                new Brand { Id = 3, Name = "Volkswagen", Logo = ImageConversion.ConvertImageToByteArray("Assets", "3.png") },
                new Brand { Id = 4, Name = "Audi", Logo = ImageConversion.ConvertImageToByteArray("Assets", "4.png") },
                new Brand { Id = 5, Name = "Peugeot", Logo = ImageConversion.ConvertImageToByteArray("Assets", "5.png") },
                new Brand { Id = 6, Name = "Renault", Logo = ImageConversion.ConvertImageToByteArray("Assets", "6.png") },
                new Brand { Id = 7, Name = "Honda", Logo = ImageConversion.ConvertImageToByteArray("Assets", "7.png") }
            );




            // Seed Vehicles
            modelBuilder.Entity<Vehicle>().HasData(
                new Vehicle
                {
                    Id = 1,
                    LicensePlate = "A123-ABC",
                    Name = "AMG GT",
                    YearOfManufacture = 2022,
                    Color = "Black",
                    BrandId = 1, // Mercedes-Benz
                    VehicleTierId = 2, // Premium
                    UserId = 2, // First driver
                    StateMachine = "Accepted",
                    PetFriendly = true,
                    SeatsCount = 3,
                    Picture = ImageConversion.ConvertImageToByteArray("Assets", "15.png")
                },
                new Vehicle
                {
                    Id = 2,
                    LicensePlate = "B456-DEF",
                    Name = "RS6 Avant",
                    YearOfManufacture = 2021,
                    Color = "White",
                    BrandId = 4, // Audi
                    VehicleTierId = 1, // Standard
                    UserId = 3, // Second driver
                    StateMachine = "Accepted",
                    PetFriendly = false,
                    SeatsCount = 4,
                    Picture = ImageConversion.ConvertImageToByteArray("Assets", "16.png")
                }
            );

            // Seed Genders
            modelBuilder.Entity<Gender>().HasData(
                new Gender { Id = 1, Name = "Male" },
                new Gender { Id = 2, Name = "Female" }
            );

            // Seed Cities
            modelBuilder.Entity<City>().HasData(
                new City { Id = 1, Name = "Sarajevo" },
                new City { Id = 2, Name = "Banja Luka" },
                new City { Id = 3, Name = "Tuzla" },
                new City { Id = 4, Name = "Zenica" },
                new City { Id = 5, Name = "Mostar" },
                new City { Id = 6, Name = "Bihać" },
                new City { Id = 7, Name = "Brčko" },
                new City { Id = 8, Name = "Bijeljina" },
                new City { Id = 9, Name = "Prijedor" },
                new City { Id = 10, Name = "Trebinje" },
                new City { Id = 11, Name = "Doboj" },
                new City { Id = 12, Name = "Cazin" },
                new City { Id = 13, Name = "Velika Kladuša" },
                new City { Id = 14, Name = "Visoko" },
                new City { Id = 15, Name = "Zavidovići" },
                new City { Id = 16, Name = "Gračanica" },
                new City { Id = 17, Name = "Konjic" },
                new City { Id = 18, Name = "Livno" },
                new City { Id = 19, Name = "Srebrenik" },
                new City { Id = 20, Name = "Gradačac" }
            );

            // Seed DriveRequestStatus
            modelBuilder.Entity<DriveRequestStatus>().HasData(
                new DriveRequestStatus 
                { 
                    Id = 1, 
                    Name = "Pending",
                    Description = "Request is waiting to be accepted by a driver"
                },
                new DriveRequestStatus 
                { 
                    Id = 2, 
                    Name = "Accepted",
                    Description = "Request has been accepted by a driver"
                },
                new DriveRequestStatus 
                { 
                    Id = 3, 
                    Name = "Completed",
                    Description = "Drive has been completed"
                },
                new DriveRequestStatus 
                { 
                    Id = 4, 
                    Name = "Cancelled",
                    Description = "Request has been cancelled"
                }
            );

            // Seed DriveRequests (Completed)
            modelBuilder.Entity<DriveRequest>().HasData(
                // User 4's first completed drive (Premium tier)
                new DriveRequest
                {
                    Id = 1,
                    UserId = 4, // Ajla Frašto
                    VehicleTierId = 2, // Premium
                    DriverId = 2, // Amel Musić
                    VehicleId = 1, // Mercedes-Benz E-Class
                    StartLocation = "43.8562586,18.4130763", // Sarajevo City Center (Baščaršija)
                    EndLocation = "43.8247222,18.3313889", // Sarajevo International Airport
                    BasePrice = 20.00m,
                    FinalPrice = 25.00m,
                    CreatedAt = fixedDate.AddDays(-5),
                    AcceptedAt = fixedDate.AddDays(-5).AddHours(1),
                    CompletedAt = fixedDate.AddDays(-5).AddHours(2),
                    StatusId = 3 // Completed
                },
                // User 4's second completed drive (Standard tier)
                new DriveRequest
                {
                    Id = 2,
                    UserId = 4, // Ajla Frašto
                    VehicleTierId = 1, // Standard
                    DriverId = 3, // Adil Joldić
                    VehicleId = 2, // Volkswagen Passat
                    StartLocation = "44.2019444,17.9080556", // Zenica Train Station
                    EndLocation = "44.2036111,17.9077778", // Zenica City Center (Trg Alije Izetbegovića)
                    BasePrice = 10.00m,
                    FinalPrice = 12.00m,
                    CreatedAt = fixedDate.AddDays(-3),
                    AcceptedAt = fixedDate.AddDays(-3).AddHours(1),
                    CompletedAt = fixedDate.AddDays(-3).AddHours(2),
                    StatusId = 3 // Completed
                },
                // User 5's completed drive (Premium tier)
                new DriveRequest
                {
                    Id = 3,
                    UserId = 5, // Elmir Babović
                    VehicleTierId = 2, // Premium
                    DriverId = 2, // Amel Musić
                    VehicleId = 1, // Mercedes-Benz E-Class
                    StartLocation = "43.3372222,17.8150000", // Mostar Old Bridge (Stari Most)
                    EndLocation = "43.3458333,17.8083333", // Mostar Train Station
                    BasePrice = 15.00m,
                    FinalPrice = 18.00m,
                    CreatedAt = fixedDate.AddDays(-2),
                    AcceptedAt = fixedDate.AddDays(-2).AddHours(1),
                    CompletedAt = fixedDate.AddDays(-2).AddHours(2),
                    StatusId = 3 // Completed
                }
            );

            // Seed Reviews
            modelBuilder.Entity<Review>().HasData(
                // Review for User 4's first drive
                new Review
                {
                    Id = 1,
                    DriveRequestId = 1,
                    UserId = 4, // Ajla Frašto
                    Rating = 5,
                    Comment = "Excellent service! The driver was very professional and the car was comfortable.",
                    CreatedAt = fixedDate.AddDays(-5).AddHours(3)
                },
                // Review for User 4's second drive
                new Review
                {
                    Id = 2,
                    DriveRequestId = 2,
                    UserId = 4, // Ajla Frašto
                    Rating = 4,
                    Comment = "Good ride, everything was on time.",
                    CreatedAt = fixedDate.AddDays(-3).AddHours(3)
                },
                // Review for User 5's drive
                new Review
                {
                    Id = 3,
                    DriveRequestId = 3,
                    UserId = 5, // Elmir Babović
                    Rating = 5,
                    Comment = "Perfect experience! Will definitely use this service again.",
                    CreatedAt = fixedDate.AddDays(-2).AddHours(3)
                }
            );

            // Seed Chats (User <-> Driver communication, exclude admin)
            // List of user and driver IDs (excluding admin)
            var userIds = new[] { 4, 5 }; // Users: Ajla Frašto, Elmir Babović
            var driverIds = new[] { 2, 3 }; // Drivers: Amel Musić, Adil Joldić

            int chatId = 1;
            foreach (var userId in userIds)
            {
                foreach (var driverId in driverIds)
                {
                    // User sends "Hello World" to Driver
                    modelBuilder.Entity<Chat>().HasData(new Chat
                    {
                        Id = chatId++,
                        SenderId = userId,
                        ReceiverId = driverId,
                        Message = "Hello World",
                        CreatedAt = fixedDate.AddDays(-1).AddHours(chatId),
                        IsRead = false
                    });

                    // Driver replies "Hello World" to User
                    modelBuilder.Entity<Chat>().HasData(new Chat
                    {
                        Id = chatId++,
                        SenderId = driverId,
                        ReceiverId = userId,
                        Message = "Hello World",
                        CreatedAt = fixedDate.AddDays(-1).AddHours(chatId),
                        IsRead = false
                    });
                }
            }
        }





    }
} 