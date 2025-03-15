using System.ComponentModel.DataAnnotations;

namespace OpenIddictDemo.Models
{
    public class PaymentModel
    {
        [Required]
        public string UserId { get; set; } = string.Empty;
        
        [Required]
        public string BillId { get; set; } = string.Empty;
        
        [Required]
        [Range(1, int.MaxValue)]
        public int BillCategory { get; set; }
        
        [Required]
        [Range(2000, 9999)]
        public int Year { get; set; }
        
        [Required]
        [Range(1, int.MaxValue)]
        public int BillNumber { get; set; }
        
        [Required]
        public Customer Customer { get; set; } = new();
        
        [Required]
        [Range(0.01, double.MaxValue)]
        public decimal Amount { get; set; }
        
        [Required]
        public DateTime EffectiveDate { get; set; }
        
        [Required]
        [MinLength(1)]
        public List<PaymentLine> PaymentLines { get; set; } = new();
        
        [Required]
        [Range(1, int.MaxValue)]
        public int TransactionNumber { get; set; }
        
        [Required]
        public Tender Tender { get; set; } = new();
        
        [Required]
        public ExternalSystem ExternalSystem { get; set; } = new();
    }
}