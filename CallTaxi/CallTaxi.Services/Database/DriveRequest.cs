using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

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

        // Driver and Vehicle are nullable as they're only set when request is accepted
        public int? DriverId { get; set; }
        public int? VehicleId { get; set; }

        [Required]
        [MaxLength(100)]
        public string StartLocation { get; set; } = string.Empty;

        [Required]
        [MaxLength(100)]
        public string EndLocation { get; set; } = string.Empty;

        [Required]
        public decimal Distance { get; set; }

        [Required]
        public decimal BasePrice { get; set; }

        [Required]
        public decimal FinalPrice { get; set; }

        [Required]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public DateTime? AcceptedAt { get; set; }

        public DateTime? CompletedAt { get; set; }

        [Required]
        public int StatusId { get; set; }

        // Navigation properties
        [ForeignKey("UserId")]
        public User User { get; set; } = null!;

        [ForeignKey("DriverId")]
        public User? Driver { get; set; }

        [ForeignKey("VehicleId")]
        public Vehicle? Vehicle { get; set; }

        [ForeignKey("VehicleTierId")]
        public VehicleTier VehicleTier { get; set; } = null!;

        [ForeignKey("StatusId")]
        public DriveRequestStatus Status { get; set; } = null!;
    }
} 