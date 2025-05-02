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


        /// <summary>
        /// Only test if RabbitMQ is installed and CallTaxi.Subscriber project is started
        /// </summary>
        [HttpPost]
        [Authorize(Roles = "Administrator,Driver")]
        public override async Task<VehicleResponse> Create([FromBody] VehicleInsertRequest request)
        {
            return await _crudService.CreateAsync(request);
        }


        /// <summary>
        /// Only test if RabbitMQ is installed and CallTaxi.Subscriber project is started
        /// </summary>
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

        /// <summary>
        /// Changes StateMachine in Vehicle from Pending to Accepted
        /// </summary>
        [HttpPut("{id}/accept")]
        [Authorize(Roles = "Administrator")]
        public virtual async Task<VehicleResponse?> AcceptAsync(int id)
        {
            return await _vehicleService.AcceptAsync(id);
        }

        /// <summary>
        /// Changes StateMachine in Vehicle from Pending to Rejected
        /// </summary>
        [HttpPut("{id}/reject")]
        [Authorize(Roles = "Administrator")]
        public virtual async Task<VehicleResponse?> RejectAsync(int id)
        {
            return await _vehicleService.RejectAsync(id);
        }

    }
} 