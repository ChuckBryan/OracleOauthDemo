namespace OpenIddictDemo.Models
{
    public class Customer
    {
        public int Id { get; set; }
        public string PrimaryName { get; set; } = string.Empty;
        public string SecondaryName { get; set; } = string.Empty;
        public string PhoneNumber { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public Address? Address { get; set; }
    }
}