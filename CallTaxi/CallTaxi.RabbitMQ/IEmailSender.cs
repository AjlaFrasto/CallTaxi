using System.Threading.Tasks;

namespace CallTaxi.RabbitMQ
{
    public interface IEmailSender
    {
        Task SendEmailAsync(string email, string subject, string message);
    }
} 