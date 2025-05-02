using System;
using CallTaxi.RabbitMQ.Models;

namespace CallTaxi.RabbitMQ
{
    public class VehicleNotification
    {
        public VehicleNotificationDto Vehicle { get; set; } = null!;
    }
} 