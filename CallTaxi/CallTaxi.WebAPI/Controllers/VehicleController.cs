using CallTaxi.Model.Requests;
using CallTaxi.Model.Responses;
using CallTaxi.Model.SearchObjects;
using CallTaxi.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace CallTaxi.WebAPI.Controllers
{
    public class VehicleController : BaseCRUDController<VehicleResponse, VehicleSearchObject, VehicleInsertRequest, VehicleUpdateRequest>
    {
        IVehicleService _vehicleService;
        public VehicleController(IVehicleService service) : base(service)
        {
            _vehicleService = service;
        }

        [HttpPost]
        [Authorize(Roles = "Administrator,Driver")]
        public override async Task<VehicleResponse> Create([FromBody] VehicleInsertRequest request)
        {
            return await _crudService.CreateAsync(request);
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "Administrator,Driver")]
        public override async Task<VehicleResponse?> Update(int id, [FromBody] VehicleUpdateRequest request)
        {
            return await _crudService.UpdateAsync(id, request);
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = "Administrator,Driver")]
        public override async Task<bool> Delete(int id)
        {
            return await _crudService.DeleteAsync(id);
        }

        [HttpPut("{id}/activate")]
        [Authorize(Roles = "Administrator")]
        public virtual async Task<VehicleResponse?> AcceptAsync(int id)
        {
            return await _vehicleService.AcceptAsync(id);
        }

        [HttpPut("{id}/deactivate")]
        [Authorize(Roles = "Administrator")]
        public virtual async Task<VehicleResponse?> RejectAsync(int id)
        {
            return await _vehicleService.RejectAsync(id);
        }

    }
} 