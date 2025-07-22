// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverRequest _$DriverRequestFromJson(Map<String, dynamic> json) =>
    DriverRequest(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      userFullName: json['userFullName'] as String?,
      vehicleTierId: (json['vehicleTierId'] as num?)?.toInt() ?? 0,
      vehicleTierName: json['vehicleTierName'] as String?,
      driverId: (json['driverId'] as num?)?.toInt(),
      driverFullName: json['driverFullName'] as String?,
      vehicleId: (json['vehicleId'] as num?)?.toInt(),
      vehicleName: json['vehicleName'] as String?,
      vehicleLicensePlate: json['vehicleLicensePlate'] as String?,
      startLocation: json['startLocation'] as String?,
      endLocation: json['endLocation'] as String?,
      basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0.0,
      finalPrice: (json['finalPrice'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      acceptedAt: json['acceptedAt'] == null
          ? null
          : DateTime.parse(json['acceptedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      statusId: (json['statusId'] as num?)?.toInt() ?? 0,
      statusName: json['statusName'] as String?,
    );

Map<String, dynamic> _$DriverRequestToJson(DriverRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'userFullName': instance.userFullName,
      'vehicleTierId': instance.vehicleTierId,
      'vehicleTierName': instance.vehicleTierName,
      'driverId': instance.driverId,
      'driverFullName': instance.driverFullName,
      'vehicleId': instance.vehicleId,
      'vehicleName': instance.vehicleName,
      'vehicleLicensePlate': instance.vehicleLicensePlate,
      'startLocation': instance.startLocation,
      'endLocation': instance.endLocation,
      'basePrice': instance.basePrice,
      'finalPrice': instance.finalPrice,
      'createdAt': instance.createdAt.toIso8601String(),
      'acceptedAt': instance.acceptedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'statusId': instance.statusId,
      'statusName': instance.statusName,
    };
