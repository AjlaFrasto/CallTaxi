using System.ComponentModel.DataAnnotations;

namespace CallTaxi.Model.Requests
{
    public class VehicleInsertRequest
    {
        [Required]
        [MaxLength(50)]
        public string Name { get; set; }

        [Required]
        [MaxLength(20)]
        public string LicensePlate { get; set; }

        [Required]
        [MaxLength(30)]
        public string Color { get; set; }

        [Required]
        [Range(1900, 2100, ErrorMessage = "Year of manufacture must be between 1900 and 2100.")]
        public int YearOfManufacture { get; set; }

        [Required]
        [Range(1, 20, ErrorMessage = "Seat count must be between 1 and 20.")]
        public int SeatsCount { get; set; }
        public byte[]? Picture { get; set; }

        [Required]
        public bool PetFriendly { get; set; }

        [Required]
        public int BrandId { get; set; }

        [Required]
        public int UserId { get; set; }

        [Required]
        public int VehicleTierId { get; set; }
    }
} 