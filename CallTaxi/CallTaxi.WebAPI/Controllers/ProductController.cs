using eCommerce.Model;
using eCommerce.Model.SearchObjects;
using eCommerce.Services;
using Microsoft.AspNetCore.Mvc;

namespace eCommerce.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ProductController : ControllerBase
    {
        protected readonly IProductService _productService;
        public ProductController(IProductService service) {
            _productService = service;
        }

        [HttpGet("")]
        public IEnumerable<Product> Get([FromQuery]ProductSearchObject? search)
        {
            return _productService.Get(search);
        }

        [HttpGet("{id}")]
        public Product Get(int id)
        {
            return _productService.Get(id);
        }
    }
}
