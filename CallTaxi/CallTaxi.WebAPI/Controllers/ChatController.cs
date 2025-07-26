using CallTaxi.Model.Requests;
using CallTaxi.Model.Responses;
using CallTaxi.Model.SearchObjects;
using CallTaxi.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace CallTaxi.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ChatController : BaseCRUDController<ChatResponse, ChatSearchObject, ChatUpsertRequest, ChatUpsertRequest>
    {
        private readonly IChatService _chatService;

        public ChatController(IChatService service) : base(service)
        {
            _chatService = service;
        }

        [HttpPost("{id}/read")]
        public async Task<IActionResult> MarkAsRead(int id)
        {
            var result = await _chatService.MarkAsReadAsync(id);
            if (!result)
                return NotFound();

            return Ok();
        }

        [HttpGet("unread-count")]
        public async Task<ActionResult<int>> GetUnreadCount([FromQuery] int userId)
        {
            return await _chatService.GetUnreadCountAsync(userId);
        }

        [HttpPost("mark-conversation-read")]
        public async Task<IActionResult> MarkConversationAsRead([FromQuery] int senderId, [FromQuery] int receiverId)
        {
            var result = await _chatService.MarkConversationAsReadAsync(senderId, receiverId);
            if (!result)
                return NotFound();

            return Ok();
        }
    }
} 