using System.ComponentModel.DataAnnotations;

namespace OpenIddictDemo.Models
{
    public class PaymentLine
    {
        [Required]
        public string Id { get; set; } = string.Empty;

        [Required]
        public string Code { get; set; } = string.Empty;

        [Required]
        [Range(0.01, double.MaxValue)]
        public decimal Amount { get; set; }

        [Required]
        [MinLength(1)]
        public List<PaymentLineAmount> PaymentLineAmounts { get; set; } = new();
    }
}