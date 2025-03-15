using System.ComponentModel.DataAnnotations;

namespace OpenIddictDemo.Models
{
    public class Tender
    {
        [Required]
        public TenderMethod Method { get; set; } = new();
        
        [Required]
        public string PaidBy { get; set; } = string.Empty;
        
        public string? Deposit { get; set; }
        
        public string? Memo { get; set; }
        
        [Required]
        public string Reference { get; set; } = string.Empty;
    }
}