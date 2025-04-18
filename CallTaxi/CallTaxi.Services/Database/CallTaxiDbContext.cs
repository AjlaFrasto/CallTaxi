using Microsoft.EntityFrameworkCore;

namespace eCommerce.Services.Database
{
    public class CallTaxiDbContext : DbContext
    {
        public CallTaxiDbContext(DbContextOptions<CallTaxiDbContext> options) : base(options)
        {
        }

        public DbSet<User> Users { get; set; }
        public DbSet<Product> Products { get; set; }
    

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
                
            // Configure Product entity
            modelBuilder.Entity<Product>()
                .HasIndex(p => p.Name);
                
            modelBuilder.Entity<Product>()
                .HasIndex(p => p.SKU)
                .IsUnique()
                .HasFilter("[SKU] IS NOT NULL");
                
 
        }
    }
} 