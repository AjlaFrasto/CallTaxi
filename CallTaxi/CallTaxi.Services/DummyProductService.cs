using eCommerce.Model;
using eCommerce.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eCommerce.Services
{
    public class DummyProductService : IProductService
    {
        public virtual List<Product> Get(ProductSearchObject search)
        {
            List<Product> products = new List<Product>();
            products.Add(new Product()
            {
                Id = 1,
                Code = "Laptop"
            });

            


            //List<Product> productsTmp = new List<Product>();
            //foreach(Product product in products)
            //{
            //    if (!string.IsNullOrWhiteSpace(search?.Code))
            //    {
            //        if (product.Code.Equals(search?.Code)) productsTmp.Add(product);
            //    }
            //}


            var queryable = products.AsQueryable();
            //var result = from product in queryable
            //             where search.Code != null && product.Code == search.Code
            //             select product;
            if (!string.IsNullOrWhiteSpace(search?.Code))
            {
                queryable = queryable.Where(x => x.Code == search.Code);
            }
            
            if(!string.IsNullOrWhiteSpace(search?.CodeGTE))
            {
                queryable = queryable.Where(x => x.Code.StartsWith(search.CodeGTE));
            }

            if (!string.IsNullOrWhiteSpace(search?.FTS))
            {
                queryable = queryable.Where(x => x.Code.Contains(search.FTS, StringComparison.CurrentCultureIgnoreCase) || (x.Name != null && x.Name.Contains(search.FTS, StringComparison.CurrentCultureIgnoreCase)));
            }

            return queryable.ToList();
        }

        public virtual Product Get(int id)
        {
            return new Product()
            {
                Id = 1,
                Code = "Laptop"
            };
        }
    }
}
