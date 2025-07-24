import 'package:json_annotation/json_annotation.dart';

part 'vehicle.g.dart';

@JsonSerializable()
class Vehicle {
  final int id;
  final String name;
  final String licensePlate;
  final String color;
  final int yearOfManufacture;
  final int seatsCount;
  final String stateMachine;
  final String? picture; // base64 string
  final bool petFriendly;
  final int brandId;
  final String brandName;
  final String? brandLogo; // base64 string
  final int userId;
  final String? userFullName;
  final int vehicleTierId;
  final String? vehicleTierName;

  Vehicle({
    this.id = 0,
    this.name = '',
    this.licensePlate = '',
    this.color = '',
    this.yearOfManufacture = 0,
    this.seatsCount = 0,
    this.stateMachine = '',
    this.picture,
    this.petFriendly = false,
    this.brandId = 0,
    this.brandName = '',
    this.brandLogo,
    this.userId = 0,
    this.userFullName,
    this.vehicleTierId = 0,
    this.vehicleTierName,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) =>
      _$VehicleFromJson(json);
  Map<String, dynamic> toJson() => _$VehicleToJson(this);
}
