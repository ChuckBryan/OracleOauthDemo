using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using OpenIddictDemo.Models;

namespace OpenIddictDemo.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class PaymentController : ControllerBase
    {
        [HttpPost]
        public ActionResult<PaymentResponse> ProcessPayment([FromBody] PaymentModel payment)
        {
            // In a real application, you would process the payment here
            // For this demo, we'll create a simple response
            var response = new PaymentResponse
            {
                PaymentId = Guid.NewGuid().ToString(),
                ExternalBatchNumber = 1,
                ExternalPaymentId = new Random().Next(1000, 9999),
                ReceiptNumber = new Random().Next(10000, 99999),
                MunisBatchId = $"BATCH_{DateTime.UtcNow:yyyyMMdd}",
                PaymentLines = payment.PaymentLines // Return the same payment lines from the request
            };

            return Ok(response);
        }
    }
}