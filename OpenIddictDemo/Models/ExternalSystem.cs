using System.ComponentModel.DataAnnotations;

namespace OpenIddictDemo.Models
{
    public class ExternalSystem
    {
        [Required]
        [Range(1, int.MaxValue)]
        public int ExternalBatchId { get; set; }
        
        [Required]
        [Range(1, int.MaxValue)]
        public int ExternalBatchNumber { get; set; }
        
        [Required]
        [Range(1, int.MaxValue)]
        public int ExternalPaymentId { get; set; }
    }
}