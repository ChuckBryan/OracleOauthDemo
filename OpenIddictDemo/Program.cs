using Microsoft.EntityFrameworkCore;
using OpenIddict.Abstractions;
using OpenIddict.Validation.AspNetCore;
using OpenIddictDemo.Data;
using Microsoft.OpenApi.Models;
using Microsoft.AspNetCore.HttpLogging;
using Microsoft.Extensions.Logging;

var builder = WebApplication.CreateBuilder(args);

// Configure logging to always show debug logs for OpenIddict regardless of environment
builder.Logging.ClearProviders();
builder.Logging.AddConsole();
builder.Logging.AddDebug();
builder.Logging.SetMinimumLevel(LogLevel.Information);
builder.Logging.AddFilter("OpenIddict", LogLevel.Debug);
builder.Logging.AddFilter("OpenIddict.Server", LogLevel.Debug);
builder.Logging.AddFilter("OpenIddict.Validation", LogLevel.Debug);
builder.Logging.AddFilter("Microsoft.AspNetCore.HttpLogging", LogLevel.Information);

// Add HTTP request/response logging with enhanced request body logging
builder.Services.AddHttpLogging(logging =>
{
    logging.LoggingFields = HttpLoggingFields.All;
    logging.RequestHeaders.Add("Authorization");
    logging.RequestHeaders.Add("Content-Type");
    logging.ResponseHeaders.Add("Content-Type");
    logging.MediaTypeOptions.AddText("application/x-www-form-urlencoded");
    logging.RequestBodyLogLimit = 4096;
    logging.ResponseBodyLogLimit = 4096;
});

// Add services to the container.
builder.Services.AddControllers();

// Configure CORS policy
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

// Configure Authentication and Authorization
builder.Services.AddAuthentication(options =>
{
    options.DefaultScheme = OpenIddictValidationAspNetCoreDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = OpenIddictValidationAspNetCoreDefaults.AuthenticationScheme;
});
builder.Services.AddAuthorization();

// Register the database context with SQL Server
builder.Services.AddDbContext<ApplicationDbContext>(options =>
{
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection"));
    options.UseOpenIddict();
});

// Configure OpenIddict
builder.Services.AddOpenIddict()
    // Register the OpenIddict core components
    .AddCore(options =>
    {
        // Configure OpenIddict to use the Entity Framework Core stores and models
        options.UseEntityFrameworkCore()
               .UseDbContext<ApplicationDbContext>();
    })
    // Register the OpenIddict server components
    .AddServer(options =>
    {
        // Enable the token endpoint
        options.SetTokenEndpointUris("connect/token");

        // Register the supported scopes
        options.RegisterScopes("api");

        // Enable the client credentials flow
        options.AllowClientCredentialsFlow();

        // Register the signing and encryption credentials
        options.AddDevelopmentEncryptionCertificate()
               .AddDevelopmentSigningCertificate();

        // Register the ASP.NET Core host and configure the ASP.NET Core-specific options
        options.UseAspNetCore()
               .EnableTokenEndpointPassthrough()
               .DisableTransportSecurityRequirement(); // Disable HTTPS requirement
    })
    // Register the OpenIddict validation components
    .AddValidation(options =>
    {
        // Import the configuration from the local OpenIddict server instance.
        options.UseLocalServer();

        // Register the ASP.NET Core host.
        options.UseAspNetCore();
    });

builder.Services.AddHostedService<TestDataSeeder>();

// Add OpenAPI/Swagger documentation
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new OpenApiInfo { Title = "OpenIddict Demo API", Version = "v1" });

    // Define the OAuth2.0 scheme that's in use
    options.AddSecurityDefinition("oauth2", new OpenApiSecurityScheme
    {
        Type = SecuritySchemeType.OAuth2,
        Flows = new OpenApiOAuthFlows
        {
            ClientCredentials = new OpenApiOAuthFlow
            {
                TokenUrl = new Uri("/connect/token", UriKind.Relative),
                Scopes = new Dictionary<string, string>
                {
                    { "api", "API access" }
                }
            }
        }
    });

    options.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "oauth2"
                }
            },
            new[] { "api" }
        }
    });
});

var app = builder.Build();

// Enable HTTP request/response logging for all environments
app.UseHttpLogging();

// Add our custom request logging middleware
app.UseMiddleware<OpenIddictDemo.RequestLoggingMiddleware>();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(options =>
    {
        options.SwaggerEndpoint("/swagger/v1/swagger.json", "OpenIddict Demo API v1");
    });

    // Initialize the database
    using (var scope = app.Services.CreateScope())
    {
        var dbContext = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        try
        {
            // Try to connect to the database
            if (!dbContext.Database.CanConnect())
            {
                // Database doesn't exist, create it
                dbContext.Database.EnsureCreated();
                Console.WriteLine("Database created successfully.");
            }
            else
            {
                Console.WriteLine("Database already exists, skipping creation.");
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error initializing database: {ex.Message}");
            // Log the error but don't throw - allow the application to continue
        }
    }
}

// Use CORS before other middleware
app.UseCors("AllowAll");

// Remove HTTPS redirection in development
if (!app.Environment.IsDevelopment())
{
    app.UseHttpsRedirection();
}

app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

app.Run();

// This class is used to seed test data for our OAuth server
public class TestDataSeeder : IHostedService
{
    private readonly IServiceProvider _serviceProvider;

    public TestDataSeeder(IServiceProvider serviceProvider)
    {
        _serviceProvider = serviceProvider;
    }

    public async Task StartAsync(CancellationToken cancellationToken)
    {
        using var scope = _serviceProvider.CreateScope();

        var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        var manager = scope.ServiceProvider.GetRequiredService<IOpenIddictApplicationManager>();

        try
        {
            // Only ensure database is created if we can't connect
            if (!context.Database.CanConnect())
            {
                await context.Database.EnsureCreatedAsync(cancellationToken);
                Console.WriteLine("Database created by TestDataSeeder.");
            }

            // Check if the test client already exists
            if (await manager.FindByClientIdAsync("test-client", cancellationToken) is null)
            {
                // Create a new client application
                await manager.CreateAsync(new OpenIddictApplicationDescriptor
                {
                    ClientId = "test-client",
                    ClientSecret = "test-secret",
                    DisplayName = "Test Client Application",
                    Permissions =
                    {
                        OpenIddictConstants.Permissions.Endpoints.Token,
                        OpenIddictConstants.Permissions.GrantTypes.ClientCredentials,
                        OpenIddictConstants.Permissions.Prefixes.Scope + "api"
                    }
                }, cancellationToken);

                Console.WriteLine("Created test client: test-client with secret: test-secret");
            }
            else
            {
                Console.WriteLine("Test client already exists, skipping creation.");
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error in TestDataSeeder: {ex.Message}");
            // Log the error but don't throw - allow the application to continue
        }
    }

    public Task StopAsync(CancellationToken cancellationToken) => Task.CompletedTask;
}
