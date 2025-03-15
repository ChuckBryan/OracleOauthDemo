namespace OpenIddictDemo.Models
{
    public class PaymentResponse
    {
        public string PaymentId { get; set; } = string.Empty;
        public int ExternalBatchNumber { get; set; }
        public int ExternalPaymentId { get; set; }
        public int ReceiptNumber { get; set; }
        public string MunisBatchId { get; set; } = string.Empty;
        public List<PaymentLine> PaymentLines { get; set; } = new();
    }
}