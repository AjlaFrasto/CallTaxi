using CallTaxi.Model.Requests;
using CallTaxi.Model.Responses;
using CallTaxi.Model.SearchObjects;
using System.Threading.Tasks;

namespace CallTaxi.Services.Interfaces
{
    public interface IDriveRequestService : ICRUDService<DriveRequestResponse, DriveRequestSearchObject, DriveRequestUpsertRequest, DriveRequestUpsertRequest>
    {
        Task<DriveRequestResponse> AcceptRequest(int id, int driverId, int vehicleId);
        Task<DriveRequestResponse> CompleteRequest(int id);
        Task<DriveRequestResponse> CancelRequest(int id);
        Task<DriveRequestResponse> MarkAsPaid(int id);
    }
} 