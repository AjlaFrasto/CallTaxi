using System.Collections.Generic;
using System.Threading.Tasks;
using CallTaxi.RabbitMQ.Models;

namespace CallTaxi.RabbitMQ.Data
{
    public interface IUserRepository
    {
        Task<List<string>> GetAdminEmailsAsync();
    }
} 