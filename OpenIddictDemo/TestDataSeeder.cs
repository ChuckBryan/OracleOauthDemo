using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using OpenIddict.Abstractions;
using OpenIddictDemo.Data;

namespace OpenIddictDemo
{
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
}
