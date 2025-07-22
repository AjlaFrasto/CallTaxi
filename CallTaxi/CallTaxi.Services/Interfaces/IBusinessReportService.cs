using System.Threading.Tasks;
using CallTaxi.Model.Responses;

namespace CallTaxi.Services.Interfaces
{
    public interface IBusinessReportService
    {
        Task<BusinessReportResponse> GetBusinessReportAsync();
    }
} 