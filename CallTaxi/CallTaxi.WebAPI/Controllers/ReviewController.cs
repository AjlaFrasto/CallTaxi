using CallTaxi.Model.Requests;
using CallTaxi.Model.Responses;
using CallTaxi.Model.SearchObjects;
using CallTaxi.Services.Interfaces;
using CallTaxi.WebAPI.Controllers;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace CallTaxi.WebAPI.Controllers
{
    public class ReviewController : BaseCRUDController<ReviewResponse, ReviewSearchObject, ReviewUpsertRequest, ReviewUpsertRequest>
    {
        public ReviewController(IReviewService service) : base(service)
        {
        }

        // Allow anonymous access to GET endpoints only
        [HttpGet]
        [AllowAnonymous]
        public override async Task<PagedResult<ReviewResponse>> Get([FromQuery] ReviewSearchObject? search = null)
        {
            return await _service.GetAsync(search ?? new ReviewSearchObject());
        }

        [HttpGet("{id}")]
        [AllowAnonymous]
        public override async Task<ReviewResponse?> GetById(int id)
        {
            return await _service.GetByIdAsync(id);
        }
    }
} 