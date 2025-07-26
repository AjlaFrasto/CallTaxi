using System;

namespace CallTaxi.Model.Responses
{
    public class ChatResponse
    {
        public int Id { get; set; }
        public int SenderId { get; set; }
        public string? SenderName { get; set; } = string.Empty;
        public byte[]? SenderPicture { get; set; }
        public int ReceiverId { get; set; }
        public string? ReceiverName { get; set; } = string.Empty;
        public byte[]? ReceiverPicture { get; set; }
        public string Message { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
        public bool IsRead { get; set; }
        public DateTime? ReadAt { get; set; }
    }
} 