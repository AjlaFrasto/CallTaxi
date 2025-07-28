using CallTaxi.Model.Requests;
using CallTaxi.Model.Responses;
using CallTaxi.Model.SearchObjects;

namespace CallTaxi.Services.Interfaces
{
    public interface IVehicleTierService : ICRUDService<VehicleTierResponse, VehicleTierSearchObject, VehicleTierUpsertRequest, VehicleTierUpsertRequest>
    {
        VehicleTierResponse RecommendForUser(int userId);
    }
}