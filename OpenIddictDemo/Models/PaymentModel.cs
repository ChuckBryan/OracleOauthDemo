namespace OpenIddictDemo.Models
{
    public class PaymentModel
    {
        public string UserId { get; set; } = string.Empty;
        public string BillId { get; set; } = string.Empty;
        public int BillCategory { get; set; }
        public int Year { get; set; }
        public int BillNumber { get; set; }
        public Customer Customer { get; set; } = new();
        public decimal Amount { get; set; }
        public DateTime EffectiveDate { get; set; }
        public List<PaymentLine> PaymentLines { get; set; } = new();
        public int TransactionNumber { get; set; }
        public Tender Tender { get; set; } = new();
        public ExternalSystem ExternalSystem { get; set; } = new();
    }
}