import 'package:json_annotation/json_annotation.dart';

part 'driver_request.g.dart';

@JsonSerializable()
class DriverRequest {
  final int id;
  final int userId;
  final String? userFullName;
  final int vehicleTierId;
  final String? vehicleTierName;
  final int? driverId;
  final String? driverFullName;
  final int? vehicleId;
  final String? vehicleName;
  final String? vehicleLicensePlate;
  final String? startLocation;
  final String? endLocation;
  final double basePrice;
  final double finalPrice;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final int statusId;
  final String? statusName;

  DriverRequest({
    this.id = 0,
    this.userId = 0,
    this.userFullName,
    this.vehicleTierId = 0,
    this.vehicleTierName,
    this.driverId,
    this.driverFullName,
    this.vehicleId,
    this.vehicleName,
    this.vehicleLicensePlate,
    this.startLocation,
    this.endLocation,
    this.basePrice = 0.0,
    this.finalPrice = 0.0,
    required this.createdAt,
    this.acceptedAt,
    this.completedAt,
    this.statusId = 0,
    this.statusName,
  });

  factory DriverRequest.fromJson(Map<String, dynamic> json) =>
      _$DriverRequestFromJson(json);
  Map<String, dynamic> toJson() => _$DriverRequestToJson(this);
}
