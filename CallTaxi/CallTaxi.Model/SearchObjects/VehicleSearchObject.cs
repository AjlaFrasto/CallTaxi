using CallTaxi.Model.SearchObjects;

namespace CallTaxi.Model.SearchObjects
{
    public class VehicleSearchObject : BaseSearchObject
    {
        public string? Name { get; set; }
        public string? LicensePlate { get; set; }
        public int? BrandId { get; set; }
        public int? UserId { get; set; }
        public int? VehicleTierId { get; set; }
        public bool? PetFriendly { get; set; }
        public string? BrandName { get; set; }
        public string? UserFullName { get; set; }
    }
} 