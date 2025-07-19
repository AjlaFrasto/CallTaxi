namespace CallTaxi.Model.Responses
{
    public class VehicleResponse
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string LicensePlate { get; set; }
        public string Color { get; set; }
        public int YearOfManufacture { get; set; }
        public int SeatsCount { get; set; }
        public string StateMachine { get; set; }
        public byte[]? Picture { get; set; }
        public bool PetFriendly { get; set; }
        public int BrandId { get; set; }
        public string BrandName { get; set; }
        public byte[]? BrandLogo { get; set; }
        public int UserId { get; set; }
        public int VehicleTierId { get; set; }
        public string VehicleTierName { get; set; }
    }
} 