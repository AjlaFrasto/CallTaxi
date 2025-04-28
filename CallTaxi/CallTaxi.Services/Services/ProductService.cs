using CallTaxi.Model;
using CallTaxi.Model.SearchObjects;
using CallTaxi.Model.Responses;
using CallTaxi.Services.Database;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CallTaxi.Model.Requests;
using MapsterMapper;
using CallTaxi.Services.Interfaces;

namespace CallTaxi.Services.Services
{
    public class ProductService : BaseCRUDService<ProductResponse, ProductSearchObject, Product, ProductInsertRequest, ProductUpdateRequest>, IProductService
    {
        public ProductService(CallTaxiDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Product> ApplyFilter(IQueryable<Product> query, ProductSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.FTS))
            {
                query = query.Where(p => p.Name.Contains(search.FTS) || p.Description.Contains(search.FTS));
            }



            return query;
        }
    }
}
