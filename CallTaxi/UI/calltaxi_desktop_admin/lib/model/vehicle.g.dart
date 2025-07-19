// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Vehicle _$VehicleFromJson(Map<String, dynamic> json) => Vehicle(
  id: (json['id'] as num?)?.toInt() ?? 0,
  name: json['name'] as String? ?? '',
  licensePlate: json['licensePlate'] as String? ?? '',
  color: json['color'] as String? ?? '',
  yearOfManufacture: (json['yearOfManufacture'] as num?)?.toInt() ?? 0,
  seatsCount: (json['seatsCount'] as num?)?.toInt() ?? 0,
  stateMachine: json['stateMachine'] as String? ?? '',
  picture: json['picture'] as String?,
  petFriendly: json['petFriendly'] as bool? ?? false,
  brandId: (json['brandId'] as num?)?.toInt() ?? 0,
  brandName: json['brandName'] as String? ?? '',
  brandLogo: json['brandLogo'] as String?,
  userId: (json['userId'] as num?)?.toInt() ?? 0,
  userFullName: json['userFullName'] as String?,
  vehicleTierId: (json['vehicleTierId'] as num?)?.toInt() ?? 0,
  vehicleTierName: json['vehicleTierName'] as String?,
);

Map<String, dynamic> _$VehicleToJson(Vehicle instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'licensePlate': instance.licensePlate,
  'color': instance.color,
  'yearOfManufacture': instance.yearOfManufacture,
  'seatsCount': instance.seatsCount,
  'stateMachine': instance.stateMachine,
  'picture': instance.picture,
  'petFriendly': instance.petFriendly,
  'brandId': instance.brandId,
  'brandName': instance.brandName,
  'brandLogo': instance.brandLogo,
  'userId': instance.userId,
  'userFullName': instance.userFullName,
  'vehicleTierId': instance.vehicleTierId,
  'vehicleTierName': instance.vehicleTierName,
};
