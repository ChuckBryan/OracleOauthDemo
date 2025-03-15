using System.ComponentModel.DataAnnotations;

namespace OpenIddictDemo.Models
{
    public class TenderMethod
    {
        [Required]
        public string TenderType { get; set; } = string.Empty;
        
        [Required]
        public string ExternalId { get; set; } = string.Empty;
        
        [Required]
        public string Classification { get; set; } = string.Empty;
    }
}