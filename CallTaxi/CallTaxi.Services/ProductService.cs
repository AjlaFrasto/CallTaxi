using eCommerce.Model;
using eCommerce.Model.SearchObjects;
using eCommerce.Model.Responses;
using eCommerce.Services.Database;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using eCommerce.Model.Requests;
using MapsterMapper;
namespace eCommerce.Services
{
    public class ProductService : BaseCRUDService<ProductResponse, ProductSearchObject, Database.Product, ProductInsertRequest, ProductUpdateRequest>, IProductService
    {
        public ProductService(eCommerceDbContext context, IMapper mapper) : base(context, mapper)
        {
        }
    }
}
