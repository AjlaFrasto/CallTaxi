using eCommerce.Model;
using eCommerce.Model.SearchObjects;
using eCommerce.Model.Responses;
using eCommerce.Services;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Threading.Tasks;
using eCommerce.Model.Requests;
using Microsoft.AspNetCore.Authorization;

namespace eCommerce.WebAPI.Controllers
{
   
    public class ProductController : BaseCRUDController<ProductResponse, ProductSearchObject, ProductInsertRequest, ProductUpdateRequest>
    {
        public ProductController(IProductService service) : base(service)
        {
        }

        [HttpPost]
        [Authorize(Roles = "Administrator")]
        public override async Task<ProductResponse> Create([FromBody] ProductInsertRequest request)
        {
            return await _crudService.CreateAsync(request);
        }
    }
}
