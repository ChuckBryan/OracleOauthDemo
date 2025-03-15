namespace OpenIddictDemo.Models
{
    public class PaymentLine
    {
        public string Id { get; set; } = string.Empty;
        public string Code { get; set; } = string.Empty;
        public decimal Amount { get; set; }
        public List<PaymentLineAmount> PaymentLineAmounts { get; set; } = new();
    }
}