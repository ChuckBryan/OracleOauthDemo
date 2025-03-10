using Microsoft.Extensions.Logging;
using System.Text;

namespace OpenIddictDemo;

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
        // Only log token endpoint requests
        if (context.Request.Path.StartsWithSegments("/connect/token"))
        {
            context.Request.EnableBuffering();

            // Read the request body
            using var reader = new StreamReader(
                context.Request.Body,
                encoding: Encoding.UTF8,
                detectEncodingFromByteOrderMarks: false,
                leaveOpen: true);

            var body = await reader.ReadToEndAsync();

            // Log the raw request body
            _logger.LogInformation("Raw token request body: {RequestBody}", body);

            // Reset the request body position for the next middleware
            context.Request.Body.Position = 0;
        }

        await _next(context);
    }
}