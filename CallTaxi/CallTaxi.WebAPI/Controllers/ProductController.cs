using CallTaxi.Model;
using CallTaxi.Model.SearchObjects;
using CallTaxi.Model.Responses;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Threading.Tasks;
using CallTaxi.Model.Requests;
using Microsoft.AspNetCore.Authorization;
using CallTaxi.Services.Interfaces;

namespace CallTaxi.WebAPI.Controllers
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
