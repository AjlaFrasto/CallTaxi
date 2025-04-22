using CallTaxi.Model.Requests;
using CallTaxi.Model.Responses;
using CallTaxi.Model.SearchObjects;
using CallTaxi.Services;
using eCommerce.WebAPI.Controllers;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace CallTaxi.WebAPI.Controllers
{
    public class VehicleController : BaseCRUDController<VehicleResponse, VehicleSearchObject, VehicleUpsertRequest, VehicleUpsertRequest>
    {
        public VehicleController(IVehicleService service) : base(service)
        {
        }

        [HttpPost]
        [Authorize(Roles = "Administrator,Driver")]
        public override async Task<VehicleResponse> Create([FromBody] VehicleUpsertRequest request)
        {
            return await _crudService.CreateAsync(request);
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "Administrator,Driver")]
        public override async Task<VehicleResponse?> Update(int id, [FromBody] VehicleUpsertRequest request)
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