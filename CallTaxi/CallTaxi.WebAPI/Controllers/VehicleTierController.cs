using CallTaxi.Model.Requests;
using CallTaxi.Model.Responses;
using CallTaxi.Model.SearchObjects;
using CallTaxi.Services;
using CallTaxi.WebAPI.Controllers;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace CallTaxi.WebAPI.Controllers
{
    public class VehicleTierController : BaseCRUDController<VehicleTierResponse, VehicleTierSearchObject, VehicleTierUpsertRequest, VehicleTierUpsertRequest>
    {
        public VehicleTierController(IVehicleTierService service) : base(service)
        {
        }

        [HttpPost]
        [Authorize(Roles = "Administrator")]
        public override async Task<VehicleTierResponse> Create([FromBody] VehicleTierUpsertRequest request)
        {
            return await _crudService.CreateAsync(request);
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "Administrator")]
        public override async Task<VehicleTierResponse?> Update(int id, [FromBody] VehicleTierUpsertRequest request)
        {
            return await _crudService.UpdateAsync(id, request);
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = "Administrator")]
        public override async Task<bool> Delete(int id)
        {
            return await _crudService.DeleteAsync(id);
        }
    }
} 