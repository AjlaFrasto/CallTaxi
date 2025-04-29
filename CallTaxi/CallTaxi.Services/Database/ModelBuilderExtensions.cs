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
                    PhoneNumber = DefaultPhoneNumber
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
                    PhoneNumber = DefaultPhoneNumber
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
                    PhoneNumber = DefaultPhoneNumber
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
                    PhoneNumber = DefaultPhoneNumber
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
                    PhoneNumber = DefaultPhoneNumber
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
                new Brand { Id = 1, Name = "Mercedes-Benz" },
                new Brand { Id = 2, Name = "BMW" },
                new Brand { Id = 3, Name = "Audi" },
                new Brand { Id = 4, Name = "Volkswagen" },
                new Brand { Id = 5, Name = "Toyota" },
                new Brand { Id = 6, Name = "Honda" },
                new Brand { Id = 7, Name = "Ford" },
                new Brand { Id = 8, Name = "Hyundai" },
                new Brand { Id = 9, Name = "Kia" },
                new Brand { Id = 10, Name = "Skoda" }
            );

            // Seed Vehicles
            modelBuilder.Entity<Vehicle>().HasData(
                new Vehicle
                {
                    Id = 1,
                    LicensePlate = "A123-ABC",
                    Name = "Mercedes-Benz E-Class",
                    YearOfManufacture = 2022,
                    Color = "Black",
                    BrandId = 1, // Mercedes-Benz
                    VehicleTierId = 2, // Premium
                    UserId = 2, // First driver
                    StateMachine = "Accepted",
                    PetFriendly = true,
                    SeatsCount = 3,
                },
                new Vehicle
                {
                    Id = 2,
                    LicensePlate = "B456-DEF",
                    Name = "Volkswagen Passat",
                    YearOfManufacture = 2021,
                    Color = "White",
                    BrandId = 4, // Volkswagen
                    VehicleTierId = 1, // Standard
                    UserId = 3, // Second driver
                    StateMachine = "Accepted",
                    PetFriendly = false,
                    SeatsCount = 4,
                }
            );
        }
    }
} 