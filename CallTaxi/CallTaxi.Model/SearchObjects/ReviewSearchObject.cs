namespace CallTaxi.Model.SearchObjects
{
    public class ReviewSearchObject : BaseSearchObject
    {
        public int? DriveRequestId { get; set; }
        public int? UserId { get; set; }
        public int? DriverId { get; set; }
        public int? MinRating { get; set; }
        public int? MaxRating { get; set; }
    }
} 