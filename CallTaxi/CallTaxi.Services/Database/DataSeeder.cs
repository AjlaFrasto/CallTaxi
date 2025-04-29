using System;
using System.Linq;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using CallTaxi.Services.Database;

namespace CallTaxi.Services.Database
{
    public static class DataSeeder
    {
        public static void SeedData(IServiceProvider serviceProvider)
        {
            using (var scope = serviceProvider.CreateScope())
            {
                var context = scope.ServiceProvider.GetRequiredService<CallTaxiDbContext>();

                // Ensure database is created and migrations are applied
                context.Database.Migrate();

                // Seed Roles if they don't exist
                if (!context.Roles.Any())
                {
                    var roles = new[]
                    {
                        new Role { Name = "Administrator", Description = "System administrator with full access" },
                        new Role { Name = "Driver", Description = "Taxi driver role" },
                        new Role { Name = "User", Description = "Regular user role" }
                    };

                    context.Roles.AddRange(roles);
                    context.SaveChanges();
                }

                // Seed Users if they don't exist
                if (!context.Users.Any())
                {
                    // Get roles
                    var adminRole = context.Roles.First(r => r.Name == "Administrator");
                    var driverRole = context.Roles.First(r => r.Name == "Driver");
                    var userRole = context.Roles.First(r => r.Name == "User");

                    // Create users
                    var users = new[]
                    {
                        // Admin
                        new User
                        {
                            FirstName = "Admin",
                            LastName = "User",
                            Email = "admin@example.com",
                            Username = "admin",
                            PasswordHash = "hashed_password", // You should replace this with actual hashed password
                            PasswordSalt = "salt", // You should replace this with actual salt
                            IsActive = true,
                            CreatedAt = DateTime.UtcNow,
                            UserRoles = new List<UserRole>
                            {
                                new UserRole { Role = adminRole, DateAssigned = DateTime.UtcNow }
                            }
                        },
                        // Drivers
                        new User
                        {
                            FirstName = "Driver",
                            LastName = "One",
                            Email = "driver1@example.com",
                            Username = "driver1",
                            PasswordHash = "hashed_password",
                            PasswordSalt = "salt",
                            IsActive = true,
                            CreatedAt = DateTime.UtcNow,
                            UserRoles = new List<UserRole>
                            {
                                new UserRole { Role = driverRole, DateAssigned = DateTime.UtcNow }
                            }
                        },
                        new User
                        {
                            FirstName = "Driver",
                            LastName = "Two",
                            Email = "driver2@example.com",
                            Username = "driver2",
                            PasswordHash = "hashed_password",
                            PasswordSalt = "salt",
                            IsActive = true,
                            CreatedAt = DateTime.UtcNow,
                            UserRoles = new List<UserRole>
                            {
                                new UserRole { Role = driverRole, DateAssigned = DateTime.UtcNow }
                            }
                        },
                        // Regular Users
                        new User
                        {
                            FirstName = "User",
                            LastName = "One",
                            Email = "user1@example.com",
                            Username = "user1",
                            PasswordHash = "hashed_password",
                            PasswordSalt = "salt",
                            IsActive = true,
                            CreatedAt = DateTime.UtcNow,
                            UserRoles = new List<UserRole>
                            {
                                new UserRole { Role = userRole, DateAssigned = DateTime.UtcNow }
                            }
                        },
                        new User
                        {
                            FirstName = "User",
                            LastName = "Two",
                            Email = "user2@example.com",
                            Username = "user2",
                            PasswordHash = "hashed_password",
                            PasswordSalt = "salt",
                            IsActive = true,
                            CreatedAt = DateTime.UtcNow,
                            UserRoles = new List<UserRole>
                            {
                                new UserRole { Role = userRole, DateAssigned = DateTime.UtcNow }
                            }
                        }
                    };

                    context.Users.AddRange(users);
                    context.SaveChanges();
                }
            }
        }
    }
} 