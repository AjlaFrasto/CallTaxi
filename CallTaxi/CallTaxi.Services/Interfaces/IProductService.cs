using CallTaxi.Model;
using CallTaxi.Model.SearchObjects;
using CallTaxi.Model.Responses;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CallTaxi.Model.Requests;

namespace CallTaxi.Services.Interfaces
{
    public interface IProductService : ICRUDService<ProductResponse, ProductSearchObject, ProductInsertRequest, ProductUpdateRequest>
    {
    }
}
