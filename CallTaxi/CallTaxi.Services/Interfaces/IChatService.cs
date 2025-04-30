using CallTaxi.Model.Requests;
using CallTaxi.Model.Responses;
using CallTaxi.Model.SearchObjects;
using System.Threading.Tasks;

namespace CallTaxi.Services.Interfaces
{
    public interface IChatService : ICRUDService<ChatResponse, ChatSearchObject, ChatUpsertRequest, ChatUpsertRequest>
    {
        Task<bool> MarkAsReadAsync(int chatId);
        Task<int> GetUnreadCountAsync(int userId);
    }
} 