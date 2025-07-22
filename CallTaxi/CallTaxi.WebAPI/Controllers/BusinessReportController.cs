using System.Threading.Tasks;
using CallTaxi.Model.Responses;
using CallTaxi.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace CallTaxi.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class BusinessReportController : ControllerBase
    {
        private readonly IBusinessReportService _businessReportService;
        public BusinessReportController(IBusinessReportService businessReportService)
        {
            _businessReportService = businessReportService;
        }

        [HttpGet]
        public async Task<ActionResult<BusinessReportResponse>> Get()
        {
            var report = await _businessReportService.GetBusinessReportAsync();
            return Ok(report);
        }
    }
} 