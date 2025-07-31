using CallTaxi.Model.Requests;
using CallTaxi.Model.Responses;
using CallTaxi.Model.SearchObjects;
using CallTaxi.Services.Database;
using CallTaxi.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace CallTaxi.Services.Services
{
    public class ChatService : BaseCRUDService<ChatResponse, ChatSearchObject, Chat, ChatUpsertRequest, ChatUpsertRequest>, IChatService
    {
        public ChatService(CallTaxiDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Chat> ApplyFilter(IQueryable<Chat> query, ChatSearchObject search)
        {
            query = query.Include(c => c.Sender)
                        .Include(c => c.Receiver);

            if (search.SenderId.HasValue)
            {
                query = query.Where(c => c.SenderId == search.SenderId.Value);
            }

            if (search.ReceiverId.HasValue)
            {
                query = query.Where(c => c.ReceiverId == search.ReceiverId.Value);
            }

            if (search.IsRead.HasValue)
            {
                query = query.Where(c => c.IsRead == search.IsRead.Value);
            }

            if (search.OnlyUnread == true)
            {
                query = query.Where(c => !c.IsRead);
            }

            if (!string.IsNullOrEmpty(search.FTS))
            {
                query = query.Where(c => c.Message.Contains(search.FTS));
            }

            return query.OrderByDescending(c => c.CreatedAt);
        }

        protected override async Task BeforeInsert(Chat entity, ChatUpsertRequest request)
        {
            entity.CreatedAt = DateTime.Now;
            entity.IsRead = false;
            await Task.CompletedTask;
        }

 
        public async Task<bool> MarkAsReadAsync(int chatId)
        {
            var chat = await _context.Chats.FindAsync(chatId);
            if (chat == null || chat.IsRead)
                return false;

            chat.IsRead = true;
            chat.ReadAt = DateTime.Now;
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<int> GetUnreadCountAsync(int userId)
        {
            return await _context.Chats
                .Where(c => c.ReceiverId == userId && !c.IsRead)
                .CountAsync();
        }

        public async Task<bool> MarkConversationAsReadAsync(int senderId, int receiverId)
        {
            var unreadMessages = await _context.Chats
                .Where(c => c.SenderId == senderId && c.ReceiverId == receiverId && !c.IsRead)
                .ToListAsync();

            if (!unreadMessages.Any())
                return false;

            foreach (var message in unreadMessages)
            {
                message.IsRead = true;
                message.ReadAt = DateTime.Now;
            }

            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<PagedResult<ChatResponse>> GetOptimizedAsync(ChatSearchObject search)
        {
            var query = _context.Chats.AsQueryable();

            // Apply filters without including pictures
            if (search.SenderId.HasValue)
            {
                query = query.Where(c => c.SenderId == search.SenderId.Value);
            }

            if (search.ReceiverId.HasValue)
            {
                query = query.Where(c => c.ReceiverId == search.ReceiverId.Value);
            }

            if (search.IsRead.HasValue)
            {
                query = query.Where(c => c.IsRead == search.IsRead.Value);
            }

            if (search.OnlyUnread == true)
            {
                query = query.Where(c => !c.IsRead);
            }

            if (!string.IsNullOrEmpty(search.FTS))
            {
                query = query.Where(c => c.Message.Contains(search.FTS));
            }

            // Get total count
            var totalCount = await query.CountAsync();

            // Apply pagination
            var items = await query
                .OrderByDescending(c => c.CreatedAt)
                .Skip((search.Page ?? 0) * (search.PageSize ?? 10))
                .Take(search.PageSize ?? 10)
                .Select(c => new ChatResponse
                {
                    Id = c.Id,
                    SenderId = c.SenderId,
                    SenderName = $"{c.Sender.FirstName} {c.Sender.LastName}",
                    SenderPicture = null, // Exclude picture for performance
                    ReceiverId = c.ReceiverId,
                    ReceiverName = $"{c.Receiver.FirstName} {c.Receiver.LastName}",
                    ReceiverPicture = null, // Exclude picture for performance
                    Message = c.Message,
                    CreatedAt = c.CreatedAt,
                    IsRead = c.IsRead,
                    ReadAt = c.ReadAt
                })
                .ToListAsync();

            return new PagedResult<ChatResponse>
            {
                Items = items,
                TotalCount = totalCount
            };
        }

        protected override ChatResponse MapToResponse(Chat entity)
        {
            var response = _mapper.Map<ChatResponse>(entity);
            response.SenderName = $"{entity.Sender.FirstName} {entity.Sender.LastName}";
            response.SenderPicture = entity.Sender?.Picture;
            response.ReceiverName = $"{entity.Receiver.FirstName} {entity.Receiver.LastName}";
            response.ReceiverPicture = entity.Receiver?.Picture;
            return response;
        }

        public override async Task<ChatResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Chats
                .Include(c => c.Sender)
                .Include(c => c.Receiver)
                .FirstOrDefaultAsync(c => c.Id == id);

            if (entity == null)
                return null;

            return MapToResponse(entity);
        }

        public override async Task<ChatResponse> CreateAsync(ChatUpsertRequest request)
        {
            var entity = new Chat();
            MapInsertToEntity(entity, request);
            
            await BeforeInsert(entity, request);
            
            _context.Add(entity);
            await _context.SaveChangesAsync();

            // Reload the entity with includes
            return await GetByIdAsync(entity.Id) ?? throw new InvalidOperationException("Failed to create chat message");
        }

        public override async Task<ChatResponse?> UpdateAsync(int id, ChatUpsertRequest request)
        {
            var entity = await _context.Chats.FindAsync(id);
            if (entity == null)
                return null;

            MapUpdateToEntity(entity, request);
            await _context.SaveChangesAsync();

            // Reload the entity with includes after update
            return await GetByIdAsync(entity.Id);
        }
    }
} 