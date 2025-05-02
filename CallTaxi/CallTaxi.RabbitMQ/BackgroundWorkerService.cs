using EasyNetQ;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using System;
using System.Threading;
using System.Threading.Tasks;
using CallTaxi.RabbitMQ.Data;
using System.Runtime.Versioning;

namespace CallTaxi.RabbitMQ
{
    public class BackgroundWorkerService : BackgroundService
    {
        private readonly ILogger<BackgroundWorkerService> _logger;
        private readonly IEmailSender _emailSender;
        private readonly IUserRepository _userRepository;
        private readonly string _host = "localhost";
        private readonly string _username = "guest";
        private readonly string _password = "guest";
        private readonly string _virtualhost = "/";

        public BackgroundWorkerService(
            ILogger<BackgroundWorkerService> logger,
            IEmailSender emailSender,
            IUserRepository userRepository)
        {
            _logger = logger;
            _emailSender = emailSender;
            _userRepository = userRepository;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    using (var bus = RabbitHutch.CreateBus($"host={_host};virtualHost={_virtualhost};username={_username};password={_password}"))
                    {
                        bus.PubSub.Subscribe<VehicleNotification>("Vehicle_Notifications", HandleMessage);
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

        private async Task HandleMessage(VehicleNotification notification)
        {
            var adminEmails = await _userRepository.GetAdminEmailsAsync();

            if (!adminEmails.Any())
            {
                _logger.LogWarning("No admin users found to send notifications to");
                return;
            }

            var vehicle = notification.Vehicle;
            var subject = "New Vehicle Pending Review";
            var message = $"A new vehicle {vehicle.BrandName} {vehicle.Name} is ready to be accepted or rejected.\n" +
                        $"Please review and take appropriate action.";

            foreach (var email in adminEmails)
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