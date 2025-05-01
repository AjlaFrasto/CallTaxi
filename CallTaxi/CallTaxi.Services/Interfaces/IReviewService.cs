using CallTaxi.Model.Requests;
using CallTaxi.Model.Responses;
using CallTaxi.Model.SearchObjects;
using CallTaxi.Services.Interfaces;

namespace CallTaxi.Services.Interfaces
{
    public interface IReviewService : ICRUDService<ReviewResponse, ReviewSearchObject, ReviewUpsertRequest, ReviewUpsertRequest>
    {
    }
} 