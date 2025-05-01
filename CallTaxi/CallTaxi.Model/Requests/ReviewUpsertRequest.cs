using System.ComponentModel.DataAnnotations;

namespace CallTaxi.Model.Requests
{
    public class ReviewUpsertRequest
    {
        [Required]
        public int DriveRequestId { get; set; }

        [Required]
        public int UserId { get; set; }

        [Required]
        [Range(1, 5)]
        public int Rating { get; set; }

        [MaxLength(500)]
        public string? Comment { get; set; }
    }
} 