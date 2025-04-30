namespace CallTaxi.Model.SearchObjects
{
    public class ChatSearchObject : BaseSearchObject
    {
        public int? SenderId { get; set; }
        public int? ReceiverId { get; set; }
        public bool? IsRead { get; set; }
        public bool? OnlyUnread { get; set; }
    }
} 