using CallTaxi.Model.Responses;
using CallTaxi.Model.SearchObjects;
using CallTaxi.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CallTaxi.WebAPI.Controllers
{
    public class DriveRequestStatusController : BaseController<DriveRequestStatusResponse, DriveRequestStatusSearchObject>
    {
        public DriveRequestStatusController(IDriveRequestStatusService service) : base(service)
        {
        }
    }
} 