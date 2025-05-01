using Microsoft.EntityFrameworkCore;

namespace CallTaxi.Services.Database
{
    public class CallTaxiDbContext : DbContext
    {
        public CallTaxiDbContext(DbContextOptions<CallTaxiDbContext> options) : base(options)
        {
        }

        public DbSet<User> Users { get; set; }
        public DbSet<Role> Roles { get; set; }
        public DbSet<UserRole> UserRoles { get; set; }
        public DbSet<Brand> Brands { get; set; }
        public DbSet<VehicleTier> VehicleTiers { get; set; }
        public DbSet<Vehicle> Vehicles { get; set; }
        public DbSet<Gender> Genders { get; set; }
        public DbSet<City> Cities { get; set; }
        public DbSet<Chat> Chats { get; set; }
        public DbSet<DriveRequest> DriveRequests { get; set; }
        public DbSet<DriveRequestStatus> DriveRequestStatuses { get; set; }
    

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Configure User entity
            modelBuilder.Entity<User>()
                .HasIndex(u => u.Email)
                .IsUnique();

            modelBuilder.Entity<User>()
                .HasIndex(u => u.Username)
                .IsUnique();
               

            // Configure Role entity
            modelBuilder.Entity<Role>()
                .HasIndex(r => r.Name)
                .IsUnique();

            // Configure UserRole join entity
            modelBuilder.Entity<UserRole>()
                .HasOne(ur => ur.User)
                .WithMany(u => u.UserRoles)
                .HasForeignKey(ur => ur.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<UserRole>()
                .HasOne(ur => ur.Role)
                .WithMany(r => r.UserRoles)
                .HasForeignKey(ur => ur.RoleId)
                .OnDelete(DeleteBehavior.Cascade);

            // Create a unique constraint on UserId and RoleId
            modelBuilder.Entity<UserRole>()
                .HasIndex(ur => new { ur.UserId, ur.RoleId })
                .IsUnique();

            // Configure Brand entity
            modelBuilder.Entity<Brand>()
                .HasIndex(b => b.Name)
                .IsUnique();

            // Configure VehicleTier entity
            modelBuilder.Entity<VehicleTier>()
                .HasIndex(vt => vt.Name)
                .IsUnique();

            // Configure Vehicle entity
            modelBuilder.Entity<Vehicle>()
                .HasIndex(v => v.LicensePlate)
                .IsUnique();

            modelBuilder.Entity<Vehicle>()
                .HasOne(v => v.Brand)
                .WithMany()
                .HasForeignKey(v => v.BrandId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<Vehicle>()
                .HasOne(v => v.User)
                .WithMany()
                .HasForeignKey(v => v.UserId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<Vehicle>()
                .HasOne(v => v.VehicleTier)
                .WithMany()
                .HasForeignKey(v => v.VehicleTierId)
                .OnDelete(DeleteBehavior.NoAction);

            // Configure Gender entity
            modelBuilder.Entity<Gender>()
                .HasIndex(g => g.Name)
                .IsUnique();

            // Configure City entity
            modelBuilder.Entity<City>()
                .HasIndex(c => c.Name)
                .IsUnique();

            modelBuilder.Entity<User>()
                .HasOne(u => u.Gender)
                .WithMany()
                .HasForeignKey(u => u.GenderId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<User>()
                .HasOne(u => u.City)
                .WithMany()
                .HasForeignKey(u => u.CityId)
                .OnDelete(DeleteBehavior.NoAction);

            // Configure Chat entity
            modelBuilder.Entity<Chat>()
                .HasOne(c => c.Sender)
                .WithMany()
                .HasForeignKey(c => c.SenderId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<Chat>()
                .HasOne(c => c.Receiver)
                .WithMany()
                .HasForeignKey(c => c.ReceiverId)
                .OnDelete(DeleteBehavior.NoAction);

            // Configure DriveRequest entity
            modelBuilder.Entity<DriveRequest>()
                .HasOne(dr => dr.User)
                .WithMany()
                .HasForeignKey(dr => dr.UserId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<DriveRequest>()
                .HasOne(dr => dr.Driver)
                .WithMany()
                .HasForeignKey(dr => dr.DriverId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<DriveRequest>()
                .HasOne(dr => dr.Vehicle)
                .WithMany()
                .HasForeignKey(dr => dr.VehicleId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<DriveRequest>()
                .HasOne(dr => dr.VehicleTier)
                .WithMany()
                .HasForeignKey(dr => dr.VehicleTierId)
                .OnDelete(DeleteBehavior.NoAction);

            // Configure DriveRequest entity relationships
            modelBuilder.Entity<DriveRequest>()
                .HasOne(dr => dr.Status)
                .WithMany()
                .HasForeignKey(dr => dr.StatusId)
                .OnDelete(DeleteBehavior.NoAction);

            // Seed initial data
            modelBuilder.SeedData();
        }
    }
} 