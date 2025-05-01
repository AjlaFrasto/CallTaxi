using System.ComponentModel.DataAnnotations;

namespace CallTaxi.Model.Requests
{
    public class DriveRequestUpsertRequest
    {
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
        [Range(0.01, double.MaxValue, ErrorMessage = "Base price must be greater than 0")]
        public decimal BasePrice { get; set; }
    }
} 