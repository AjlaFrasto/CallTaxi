using System.Collections.Generic;
using System.Threading.Tasks;

namespace CallTaxi.Services.Interfaces
{
    public interface IUserRepository
    {
        Task<List<string>> GetAdminEmailsAsync();
    }
}