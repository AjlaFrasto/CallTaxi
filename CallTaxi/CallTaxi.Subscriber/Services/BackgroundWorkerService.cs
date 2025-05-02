using EasyNetQ;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using System;
using System.Threading;
using System.Threading.Tasks;
using System.Runtime.Versioning;
using System.Linq;
using CallTaxi.Subscriber.Models;
using CallTaxi.Subscriber.Interfaces;

namespace CallTaxi.Subscriber.Services
{
    public class BackgroundWorkerService : BackgroundService
    {
        private readonly ILogger<BackgroundWorkerService> _logger;
        private readonly IEmailSenderService _emailSender;
        private readonly string _host = "localhost";
        private readonly string _username = "guest";
        private readonly string _password = "guest";
        private readonly string _virtualhost = "/";

        public BackgroundWorkerService(
            ILogger<BackgroundWorkerService> logger,
            IEmailSenderService emailSender)
        {
            _logger = logger;
            _emailSender = emailSender;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    using (var bus = RabbitHutch.CreateBus($"host={_host};virtualHost={_virtualhost};username={_username};password={_password}"))
                    {
                        // Subscribe to vehicle notifications only
                        bus.PubSub.Subscribe<VehicleNotification>("Vehicle_Notifications", HandleVehicleMessage);

                        _logger.LogInformation("Waiting for vehicle notifications...");
                        await Task.Delay(TimeSpan.FromSeconds(5), stoppingToken);
                    }
                }
                catch (OperationCanceledException) when (stoppingToken.IsCancellationRequested)
                {
                    break;
                }
                catch (Exception ex)
                {
                    _logger.LogError($"Error in RabbitMQ listener: {ex.Message}");
                }
            }
        }

        private async Task HandleVehicleMessage(VehicleNotification notification)
        {
            var vehicle = notification.Vehicle;

            if (!vehicle.AdminEmails.Any())
            {
                _logger.LogWarning("No admin emails provided in the notification");
                return;
            }

            var subject = "New Vehicle Pending Review";
            var message = $"A new vehicle {vehicle.BrandName} {vehicle.Name} is ready to be accepted or rejected.\n" +
                        $"Please review and take appropriate action.";

            foreach (var email in vehicle.AdminEmails)
            {
                try
                {
                    await _emailSender.SendEmailAsync(email, subject, message);
                    _logger.LogInformation($"Notification sent to admin: {email}");
                }
                catch (Exception ex)
                {
                    _logger.LogError($"Failed to send email to {email}: {ex.Message}");
                }
            }
        }
    }
}