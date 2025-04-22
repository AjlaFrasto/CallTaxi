using System.ComponentModel.DataAnnotations;

namespace CallTaxi.Model.Requests
{
    public class VehicleTierUpsertRequest
    {
        [Required]
        [MaxLength(50)]
        public string Name { get; set; }

        [MaxLength(255)]
        public string? Description { get; set; }
    }
} 