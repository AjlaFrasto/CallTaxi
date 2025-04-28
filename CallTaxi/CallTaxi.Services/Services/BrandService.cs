using CallTaxi.Model.Requests;
using CallTaxi.Model.Responses;
using CallTaxi.Model.SearchObjects;
using CallTaxi.Services.Database;
using CallTaxi.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

namespace CallTaxi.Services.Services
{
    public class BrandService : BaseCRUDService<BrandResponse, BrandSearchObject, Brand, BrandUpsertRequest, BrandUpsertRequest>, IBrandService
    {
        public BrandService(CallTaxiDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Brand> ApplyFilter(IQueryable<Brand> query, BrandSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(b => b.Name.Contains(search.Name));
            }

            return query;
        }
    }
}