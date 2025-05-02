using EasyNetQ;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using System;
using System.Threading;
using System.Threading.Tasks;
using System.Runtime.Versioning;
using System.Linq;
using CallTaxi.Subscriber.Data;
using CallTaxi.Subscriber.Models;

namespace CallTaxi.Subscriber
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
                        // Subscribe to vehicle notifications
                        bus.PubSub.Subscribe<VehicleNotification>("Vehicle_Notifications", HandleVehicleMessage);
                        
                        // Subscribe to admin email updates
                        bus.PubSub.Subscribe<AdminEmailsUpdate>("Admin_Email_Updates", HandleAdminEmailsUpdate);
                        
                        _logger.LogInformation("Waiting for notifications...");
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

        private async Task HandleAdminEmailsUpdate(AdminEmailsUpdate update)
        {
            _logger.LogInformation($"Received admin emails update with {update.AdminEmails.Count} emails");
            _userRepository.UpdateNotificationRecipients(update.AdminEmails);
        }

        private async Task HandleVehicleMessage(VehicleNotification notification)
        {
            var recipients = await _userRepository.GetNotificationRecipientsAsync();

            if (!recipients.Any())
            {
                _logger.LogWarning("No recipients found to send notifications to");
                return;
            }

            var vehicle = notification.Vehicle;
            var subject = "New Vehicle Pending Review";
            var message = $"A new vehicle {vehicle.BrandName} {vehicle.Name} is ready to be accepted or rejected.\n" +
                        $"Please review and take appropriate action.";

            foreach (var email in recipients)
            {
                try
                {
                    await _emailSender.SendEmailAsync(email, subject, message);
                    _logger.LogInformation($"Notification sent to recipient: {email}");
                }
                catch (Exception ex)
                {
                    _logger.LogError($"Failed to send email to {email}: {ex.Message}");
                }
            }
        }
    }
}