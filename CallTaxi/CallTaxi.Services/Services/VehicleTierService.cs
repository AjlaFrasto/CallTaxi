using CallTaxi.Model.Requests;
using CallTaxi.Model.Responses;
using CallTaxi.Model.SearchObjects;
using CallTaxi.Services.Database;
using CallTaxi.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.ML;
using Microsoft.ML.Data;

namespace CallTaxi.Services.Services
{
    public class VehicleTierService : BaseCRUDService<VehicleTierResponse, VehicleTierSearchObject, VehicleTier, VehicleTierUpsertRequest, VehicleTierUpsertRequest>, IVehicleTierService
    {
        static MLContext mlContext = null;
        static object isLocked = new object();
        static ITransformer model = null;

        public VehicleTierService(CallTaxiDbContext context, IMapper mapper) : base(context, mapper)
        {
            // Only initialize MLContext if not already done
            if (mlContext == null)
            {
                lock (isLocked)
                {
                    if (mlContext == null)
                    {
                        mlContext = new MLContext();
                        // Model training is now handled at startup, not here
                    }
                }
            }
        }

        // Call this at backend startup to train the model once
        public static void TrainModelAtStartup(IServiceProvider serviceProvider)
        {
            lock (isLocked)
            {
                if (mlContext == null)
                {
                    mlContext = new MLContext();
                }
                using (var scope = serviceProvider.CreateScope())
                {
                    var dbContext = scope.ServiceProvider.GetRequiredService<CallTaxiDbContext>();
                    TrainModelStatic(dbContext);
                }
            }
        }

        // Static version for startup
        private static void TrainModelStatic(CallTaxiDbContext context)
        {
            var completedStatus = context.DriveRequestStatuses.FirstOrDefault(s => s.Name == "Completed");
            if (completedStatus == null)
                return;
            var data = context.DriveRequests
                .Where(dr => dr.StatusId == completedStatus.Id)
                .Select(dr => new VehicleTierSample
                {
                    UserId = (float)dr.UserId,
                    TimeOfDay = (float)dr.CreatedAt.Hour,
                    DayOfWeek = (float)((int)dr.CreatedAt.DayOfWeek),
                    VehicleTierId = (uint)dr.VehicleTierId
                })
                .ToList();
            if (!data.Any())
                return;
            var trainData = mlContext.Data.LoadFromEnumerable(data);
            var pipeline = mlContext.Transforms.CopyColumns("Label", nameof(VehicleTierSample.VehicleTierId))
                .Append(mlContext.Transforms.Conversion.MapValueToKey("Label"))
                .Append(mlContext.Transforms.Concatenate("Features", nameof(VehicleTierSample.UserId), nameof(VehicleTierSample.TimeOfDay), nameof(VehicleTierSample.DayOfWeek)))
                .Append(mlContext.MulticlassClassification.Trainers.SdcaMaximumEntropy())
                .Append(mlContext.Transforms.Conversion.MapKeyToValue("PredictedLabel"));
            model = pipeline.Fit(trainData);
        }

        protected override IQueryable<VehicleTier> ApplyFilter(IQueryable<VehicleTier> query, VehicleTierSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(vt => vt.Name.Contains(search.Name));
            }

            return query;
        }

        public VehicleTierResponse RecommendForUser(int userId)
        {
            // Use static mlContext instance
            var mlContext = VehicleTierService.mlContext;
            var completedStatus = _context.DriveRequestStatuses.FirstOrDefault(s => s.Name == "Completed");
            if (completedStatus == null)
                throw new InvalidOperationException("Completed status not found.");
            var drives = _context.DriveRequests
                .Where(dr => dr.StatusId == completedStatus.Id)
                .ToList();
            var data = new List<VehicleTierEntry>();
            foreach (var dr in drives)
            {
                data.Add(new VehicleTierEntry
                {
                    UserId = (uint)dr.UserId,
                    VehicleTierId = (uint)dr.VehicleTierId,
                    Label = 1f
                });
            }
            if (!data.Any())
            {
                // Fallback to Standard
                var standardTier = _context.VehicleTiers.FirstOrDefault(vt => vt.Name == "Standard");
                if (standardTier == null)
                    throw new InvalidOperationException("Standard vehicle tier not found.");
                return _mapper.Map<VehicleTierResponse>(standardTier);
            }
            var trainData = mlContext.Data.LoadFromEnumerable(data);
            var options = new Microsoft.ML.Trainers.MatrixFactorizationTrainer.Options
            {
                MatrixColumnIndexColumnName = nameof(VehicleTierEntry.UserId),
                MatrixRowIndexColumnName = nameof(VehicleTierEntry.VehicleTierId),
                LabelColumnName = nameof(VehicleTierEntry.Label),
                LossFunction = Microsoft.ML.Trainers.MatrixFactorizationTrainer.LossFunctionType.SquareLossOneClass,
                Alpha = 0.01,
                Lambda = 0.025,
                NumberOfIterations = 50,
                C = 0.00001
            };
            var estimator = mlContext.Recommendation().Trainers.MatrixFactorization(options);
            var model = estimator.Fit(trainData);
            var tiers = _context.VehicleTiers.ToList();
            var predictionEngine = mlContext.Model.CreatePredictionEngine<VehicleTierEntry, VehicleTierScorePrediction>(model);
            var scoredTiers = new List<(VehicleTier, float)>();
            foreach (var tier in tiers)
            {
                var prediction = predictionEngine.Predict(new VehicleTierEntry
                {
                    UserId = (uint)userId,
                    VehicleTierId = (uint)tier.Id
                });
                scoredTiers.Add((tier, prediction.Score));
            }
            var bestTier = scoredTiers.OrderByDescending(x => x.Item2).First().Item1;
            return _mapper.Map<VehicleTierResponse>(bestTier);
        }

        private VehicleTier MostUsedOrStandard(int userId)
        {
            var completedStatus = _context.DriveRequestStatuses.FirstOrDefault(s => s.Name == "Completed");
            var userDrives = _context.DriveRequests
                .Where(dr => dr.UserId == userId && dr.StatusId == completedStatus.Id)
                .ToList();
            if (userDrives.Count == 0)
            {
                var standardTier = _context.VehicleTiers.FirstOrDefault(vt => vt.Name == "Standard");
                if (standardTier == null)
                    throw new InvalidOperationException("Standard vehicle tier not found.");
                return standardTier;
            }
            var mostUsedTierId = userDrives
                .GroupBy(dr => dr.VehicleTierId)
                .OrderByDescending(g => g.Count())
                .Select(g => g.Key)
                .First();
            var tier = _context.VehicleTiers.FirstOrDefault(vt => vt.Id == mostUsedTierId);
            if (tier == null)
                throw new InvalidOperationException("Recommended vehicle tier not found.");
            return tier;
        }

        private class VehicleTierSample
        {
            public float UserId { get; set; }
            public float TimeOfDay { get; set; }
            public float DayOfWeek { get; set; }
            public uint VehicleTierId { get; set; }
        }
        private class VehicleTierPrediction
        {
            [ColumnName("PredictedLabel")]
            public uint VehicleTierId { get; set; }
        }

        public class VehicleTierScorePrediction
        {
            public float Score { get; set; }
        }
        public class VehicleTierEntry
        {
            [Microsoft.ML.Data.KeyType(count: 100)]
            public uint UserId { get; set; }
            [Microsoft.ML.Data.KeyType(count: 100)]
            public uint VehicleTierId { get; set; }
            public float Label { get; set; }
        }
    }
}