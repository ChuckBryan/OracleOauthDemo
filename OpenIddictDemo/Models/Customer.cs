using System.ComponentModel.DataAnnotations;

namespace OpenIddictDemo.Models
{
    public class Customer
    {
        [Required]
        [Range(1, int.MaxValue)]
        public int Id { get; set; }

        [Required]
        [StringLength(100)]
        public string PrimaryName { get; set; } = string.Empty;

        [StringLength(100)]
        public string? SecondaryName { get; set; }

        [Phone]
        public string? PhoneNumber { get; set; }

        [EmailAddress]
        public string? Email { get; set; }

        public Address? Address { get; set; }
    }
}