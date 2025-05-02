using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CallTaxi.Services.Interfaces
{
    public interface IAdminEmailService
    {
        Task UpdateRabbitMQAdminEmailsAsync();
    }
}
