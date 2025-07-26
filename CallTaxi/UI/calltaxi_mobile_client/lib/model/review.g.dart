// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Review _$ReviewFromJson(Map<String, dynamic> json) => Review(
  id: (json['id'] as num?)?.toInt() ?? 0,
  driveRequestId: (json['driveRequestId'] as num?)?.toInt() ?? 0,
  driverFullName: json['driverFullName'] as String?,
  driverPicture: json['driverPicture'] as String?,
  userId: (json['userId'] as num?)?.toInt() ?? 0,
  userFullName: json['userFullName'] as String?,
  rating: (json['rating'] as num?)?.toInt() ?? 0,
  comment: json['comment'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  startLocation: json['startLocation'] as String?,
  endLocation: json['endLocation'] as String?,
);

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
  'id': instance.id,
  'driveRequestId': instance.driveRequestId,
  'driverFullName': instance.driverFullName,
  'driverPicture': instance.driverPicture,
  'userId': instance.userId,
  'userFullName': instance.userFullName,
  'rating': instance.rating,
  'comment': instance.comment,
  'createdAt': instance.createdAt.toIso8601String(),
  'startLocation': instance.startLocation,
  'endLocation': instance.endLocation,
};
