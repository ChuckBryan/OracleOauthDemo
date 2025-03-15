namespace OpenIddictDemo.Models
{
    public class Tender
    {
        public TenderMethod Method { get; set; } = new();
        public string PaidBy { get; set; } = string.Empty;
        public string Deposit { get; set; } = string.Empty;
        public string Memo { get; set; } = string.Empty;
        public string Reference { get; set; } = string.Empty;
    }
}