using System.ComponentModel.DataAnnotations;

namespace CallTaxi.Model.Requests
{
    public class BrandUpsertRequest
    {
        [Required]
        [MaxLength(50)]
        public string Name { get; set; }
        public byte[]? Logo { get; set; }

    }
} 