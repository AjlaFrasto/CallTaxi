using System.ComponentModel.DataAnnotations;

namespace CallTaxi.Model.Requests
{
    public class DriveRequestAcceptRequest
    {
        [Required]
        public int DriverId { get; set; }

        [Required]
        public int VehicleId { get; set; }
    }
} 