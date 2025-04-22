using CallTaxi.Model.Requests;
using CallTaxi.Model.Responses;
using CallTaxi.Model.SearchObjects;
using eCommerce.Services;

namespace CallTaxi.Services
{
    public interface IVehicleTierService : ICRUDService<VehicleTierResponse, VehicleTierSearchObject, VehicleTierUpsertRequest, VehicleTierUpsertRequest>
    {
    }
} 