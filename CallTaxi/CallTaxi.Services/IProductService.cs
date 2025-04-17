using eCommerce.Model;
using eCommerce.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCommerce.Services
{
    public interface IProductService
    {
        public List<Product> Get(ProductSearchObject search);
        public Product Get(int id);
    }
}
