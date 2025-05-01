using CallTaxi.Model.Responses;
using CallTaxi.Model.SearchObjects;
using CallTaxi.Services.Database;
using CallTaxi.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System.Linq;

namespace CallTaxi.Services.Services
{
    public class DriveRequestStatusService : BaseService<DriveRequestStatusResponse, DriveRequestStatusSearchObject, DriveRequestStatus>, IDriveRequestStatusService
    {
        public DriveRequestStatusService(CallTaxiDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<DriveRequestStatus> ApplyFilter(IQueryable<DriveRequestStatus> query, DriveRequestStatusSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(x => x.Name.Contains(search.Name));
            }

            return query;
        }
    }
} 