using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CallTaxi.Services.Database
{
    public class Review
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public int DriveRequestId { get; set; }

        [Required]
        public int UserId { get; set; }

        [Required]
        [Range(1, 5)]
        public int Rating { get; set; }

        [MaxLength(500)]
        public string? Comment { get; set; }

        [Required]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // Navigation properties
        [ForeignKey("DriveRequestId")]
        public DriveRequest DriveRequest { get; set; } = null!;

        [ForeignKey("UserId")]
        public User User { get; set; } = null!;
    }
} 