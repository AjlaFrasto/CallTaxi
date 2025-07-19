// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: (json['id'] as num?)?.toInt() ?? 0,
  firstName: json['firstName'] as String? ?? '',
  lastName: json['lastName'] as String? ?? '',
  email: json['email'] as String? ?? '',
  username: json['username'] as String? ?? '',
  picture: json['picture'] as String?,
  isActive: json['isActive'] as bool? ?? true,
  phoneNumber: json['phoneNumber'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  lastLoginAt: json['lastLoginAt'] == null
      ? null
      : DateTime.parse(json['lastLoginAt'] as String),
  genderId: (json['genderId'] as num?)?.toInt() ?? 0,
  genderName: json['genderName'] as String? ?? '',
  cityId: (json['cityId'] as num?)?.toInt() ?? 0,
  cityName: json['cityName'] as String? ?? '',
  roles:
      (json['roles'] as List<dynamic>?)
          ?.map((e) => RoleResponse.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'email': instance.email,
  'username': instance.username,
  'picture': instance.picture,
  'isActive': instance.isActive,
  'phoneNumber': instance.phoneNumber,
  'createdAt': instance.createdAt.toIso8601String(),
  'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
  'genderId': instance.genderId,
  'genderName': instance.genderName,
  'cityId': instance.cityId,
  'cityName': instance.cityName,
  'roles': instance.roles,
};
