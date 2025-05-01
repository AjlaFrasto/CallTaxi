using System.ComponentModel.DataAnnotations;

namespace CallTaxi.Services.Database
{
    public class DriveRequest
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public int UserId { get; set; }

        [Required]
        public int VehicleTierId { get; set; }

        [Required]
        [MaxLength(100)]
        public string StartLocation { get; set; } = string.Empty;

        [Required]
        [MaxLength(100)]
        public string EndLocation { get; set; } = string.Empty;

        [Required]
        public decimal BasePrice { get; set; }

        [Required]
        public decimal FinalPrice { get; set; }

        [Required]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public DateTime? AcceptedAt { get; set; }

        public DateTime? CompletedAt { get; set; }

        [Required]
        public string Status { get; set; } = "Pending"; // Pending, Accepted, Completed, Cancelled

        // Navigation properties
        public User User { get; set; } = null!;
        public VehicleTier VehicleTier { get; set; } = null!;
    }
} 