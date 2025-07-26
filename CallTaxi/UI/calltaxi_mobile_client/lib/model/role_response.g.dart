// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoleResponse _$RoleResponseFromJson(Map<String, dynamic> json) => RoleResponse(
  id: (json['id'] as num?)?.toInt() ?? 0,
  name: json['name'] as String? ?? '',
  description: json['description'] as String? ?? '',
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$RoleResponseToJson(RoleResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'createdAt': instance.createdAt?.toIso8601String(),
      'isActive': instance.isActive,
    };
