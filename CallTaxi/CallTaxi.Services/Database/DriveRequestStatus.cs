using System.ComponentModel.DataAnnotations;

namespace CallTaxi.Services.Database
{
    public class DriveRequestStatus
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(20)]
        public string Name { get; set; } = string.Empty;

        [MaxLength(100)]
        public string? Description { get; set; }
    }
} 