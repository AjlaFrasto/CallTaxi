using CallTaxi.Model.Requests;
using CallTaxi.Model.Responses;
using CallTaxi.Model.SearchObjects;
using CallTaxi.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace CallTaxi.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class DriveRequestController : BaseCRUDController<DriveRequestResponse, DriveRequestSearchObject, DriveRequestUpsertRequest, DriveRequestUpsertRequest>
    {
        private readonly IDriveRequestService _driveRequestService;

        public DriveRequestController(IDriveRequestService service) : base(service)
        {
            _driveRequestService = service;
        }

        [HttpPost("{id}/accept")]
        public async Task<DriveRequestResponse> AcceptRequest(int id, [FromBody] DriveRequestAcceptRequest request)
        {
            return await _driveRequestService.AcceptRequest(id, request.DriverId, request.VehicleId);
        }

        [HttpPost("{id}/complete")]
        public async Task<DriveRequestResponse> CompleteRequest(int id)
        {
            return await _driveRequestService.CompleteRequest(id);
        }

        [HttpPost("{id}/cancel")]
        public async Task<DriveRequestResponse> CancelRequest(int id)
        {
            return await _driveRequestService.CancelRequest(id);
        }
    }
} 