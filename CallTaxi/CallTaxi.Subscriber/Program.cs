using CallTaxi.Subscriber;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

var builder = Host.CreateDefaultBuilder(args)
    .ConfigureServices((hostContext, services) =>
    {
        // Add RabbitMQ services
        services.AddSingleton<IEmailSender, EmailSender>();
        services.AddHostedService<BackgroundWorkerService>();
    });

var host = builder.Build();
await host.RunAsync(); 