using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using CallTaxi.RabbitMQ.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace CallTaxi.Services.Database
{
    public class UserRepository : IUserRepository
    {
        private readonly IServiceScopeFactory _scopeFactory;

        public UserRepository(IServiceScopeFactory scopeFactory)
        {
            _scopeFactory = scopeFactory;
        }

        public async Task<List<string>> GetAdminEmailsAsync()
        {
            using var scope = _scopeFactory.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<CallTaxiDbContext>();

            return await context.Users
                .Where(u => u.UserRoles.Any(ur => ur.Role.Name == "Administrator"))
                .Select(u => u.Email)
                .ToListAsync();
        }
    }
} 