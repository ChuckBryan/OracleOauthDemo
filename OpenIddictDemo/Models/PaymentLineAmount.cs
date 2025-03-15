using System.ComponentModel.DataAnnotations;

namespace OpenIddictDemo.Models
{
    public class PaymentLineAmount
    {
        [Required]
        public string Type { get; set; } = string.Empty;

        [Required]
        [Range(0.01, double.MaxValue)]
        public decimal Amount { get; set; }
    }
}