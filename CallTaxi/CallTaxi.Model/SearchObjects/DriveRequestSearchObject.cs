using System;
using CallTaxi.Model.SearchObjects;

namespace CallTaxi.Model.SearchObjects
{
    public class DriveRequestSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public int? VehicleTierId { get; set; }
        public string? Status { get; set; }
        public DateTime? CreatedFrom { get; set; }
        public DateTime? CreatedTo { get; set; }
    }
} 