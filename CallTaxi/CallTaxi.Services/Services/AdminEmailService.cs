using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using CallTaxi.Subscriber.Data;
using CallTaxi.Services.Database;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using EasyNetQ;
using CallTaxi.Subscriber.Models;

namespace CallTaxi.Services.Services
{
    public interface IAdminEmailService
    {
        Task UpdateRabbitMQAdminEmailsAsync();
    }

    public class AdminEmailService : IAdminEmailService
    {
        private readonly CallTaxiDbContext _context;
        private readonly ILogger<AdminEmailService> _logger;
        private readonly string _rabbitMqConnectionString;

        public AdminEmailService(
            CallTaxiDbContext context,
            ILogger<AdminEmailService> logger)
        {
            _context = context;
            _logger = logger;
            _rabbitMqConnectionString = "host=localhost;username=guest;password=guest";
        }

        public async Task UpdateRabbitMQAdminEmailsAsync()
        {
            _logger.LogInformation("Starting to fetch admin emails from database");
            
            var adminEmails = await _context.Users
                .Where(u => u.UserRoles.Any(ur => ur.Role.Name == "Administrator"))
                .Select(u => u.Email)
                .ToListAsync();

            _logger.LogInformation($"Found {adminEmails.Count} admin emails: {string.Join(", ", adminEmails)}");

            using var bus = RabbitHutch.CreateBus(_rabbitMqConnectionString);
            
            var update = new AdminEmailsUpdate
            {
                AdminEmails = adminEmails
            };

            await bus.PubSub.PublishAsync(update);
            
            _logger.LogInformation("Published admin emails update to RabbitMQ");
        }
    }
} 