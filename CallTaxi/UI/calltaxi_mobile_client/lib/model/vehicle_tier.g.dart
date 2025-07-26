// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_tier.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VehicleTier _$VehicleTierFromJson(Map<String, dynamic> json) => VehicleTier(
  id: (json['id'] as num?)?.toInt() ?? 0,
  name: json['name'] as String? ?? '',
  description: json['description'] as String?,
);

Map<String, dynamic> _$VehicleTierToJson(VehicleTier instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
    };
