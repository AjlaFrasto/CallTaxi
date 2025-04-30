using System.ComponentModel.DataAnnotations;

namespace CallTaxi.Model.Requests
{
    public class ChatUpsertRequest
    {
        [Required]
        public int SenderId { get; set; }

        [Required]
        public int ReceiverId { get; set; }

        [Required]
        [MaxLength(1000)]
        public string Message { get; set; } = string.Empty;
    }
} 