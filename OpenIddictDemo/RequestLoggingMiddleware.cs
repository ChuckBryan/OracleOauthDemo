using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;

namespace OpenIddictDemo
{
    public class RequestLoggingMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly ILogger<RequestLoggingMiddleware> _logger;

        public RequestLoggingMiddleware(RequestDelegate next, ILogger<RequestLoggingMiddleware> logger)
        {
            _next = next;
            _logger = logger;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            context.Request.EnableBuffering();

            var request = context.Request;
            var requestBodyContent = await ReadRequestBodyAsync(request);

            _logger.LogInformation($"Incoming request: {request.Method} {request.Path}");
            _logger.LogInformation($"Request Body: {requestBodyContent}");

            // Reset the request body stream position so the next middleware can read it
            request.Body.Position = 0;

            await _next(context);
        }

        private async Task<string> ReadRequestBodyAsync(HttpRequest request)
        {
            using (var reader = new StreamReader(request.Body, leaveOpen: true))
            {
                return await reader.ReadToEndAsync();
            }
        }
    }
}