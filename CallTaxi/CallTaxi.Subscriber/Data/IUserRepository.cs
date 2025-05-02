using System.Collections.Generic;
using System.Threading.Tasks;

namespace CallTaxi.Subscriber.Data
{
    public interface IUserRepository
    {
        Task<List<string>> GetNotificationRecipientsAsync();
        void UpdateNotificationRecipients(List<string> emails);
    }
}