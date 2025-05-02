using System.Collections.Generic;
using System.Threading.Tasks;

namespace CallTaxi.Subscriber.Data
{
    public class UserRepository : IUserRepository
    {
        private List<string> _notificationRecipients = new List<string>();

        public Task<List<string>> GetNotificationRecipientsAsync()
        {
            return Task.FromResult(_notificationRecipients);
        }

        public void UpdateNotificationRecipients(List<string> emails)
        {
            _notificationRecipients = emails ?? new List<string>();
        }
    }
}