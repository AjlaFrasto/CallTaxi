using System;

namespace CallTaxi.Model.Responses
{
    public class ReviewResponse
    {
        public int Id { get; set; }
        public int DriveRequestId { get; set; }
        public string? DriverFullName { get; set; }
        public int UserId { get; set; }
        public string? UserFullName { get; set; }
        public int Rating { get; set; }
        public string? Comment { get; set; }
        public DateTime CreatedAt { get; set; }
    }
} 