// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BusinessReport _$BusinessReportFromJson(
  Map<String, dynamic> json,
) => BusinessReport(
  driverWithHighestReviews: json['driverWithHighestReviews'] == null
      ? null
      : User.fromJson(json['driverWithHighestReviews'] as Map<String, dynamic>),
  bestDriverAverageRating: (json['bestDriverAverageRating'] as num?)
      ?.toDouble(),
  userWithMostDrives: json['userWithMostDrives'] == null
      ? null
      : User.fromJson(json['userWithMostDrives'] as Map<String, dynamic>),
  userWithMostDrivesCount: (json['userWithMostDrivesCount'] as num?)?.toInt(),
  driverWithMostDrives: json['driverWithMostDrives'] == null
      ? null
      : User.fromJson(json['driverWithMostDrives'] as Map<String, dynamic>),
  driverWithMostDrivesCount: (json['driverWithMostDrivesCount'] as num?)
      ?.toInt(),
  totalMoneyGenerated: (json['totalMoneyGenerated'] as num?)?.toDouble() ?? 0.0,
  cityWithMostUsers: json['cityWithMostUsers'] == null
      ? null
      : City.fromJson(json['cityWithMostUsers'] as Map<String, dynamic>),
  cityWithMostUsersCount: (json['cityWithMostUsersCount'] as num?)?.toInt(),
  cityWithMostDrivers: json['cityWithMostDrivers'] == null
      ? null
      : City.fromJson(json['cityWithMostDrivers'] as Map<String, dynamic>),
  cityWithMostDriversCount: (json['cityWithMostDriversCount'] as num?)?.toInt(),
  brandWithMostVehicles: json['brandWithMostVehicles'] == null
      ? null
      : Brand.fromJson(json['brandWithMostVehicles'] as Map<String, dynamic>),
  brandWithMostVehiclesCount: (json['brandWithMostVehiclesCount'] as num?)
      ?.toInt(),
);

Map<String, dynamic> _$BusinessReportToJson(BusinessReport instance) =>
    <String, dynamic>{
      'driverWithHighestReviews': instance.driverWithHighestReviews,
      'bestDriverAverageRating': instance.bestDriverAverageRating,
      'userWithMostDrives': instance.userWithMostDrives,
      'userWithMostDrivesCount': instance.userWithMostDrivesCount,
      'driverWithMostDrives': instance.driverWithMostDrives,
      'driverWithMostDrivesCount': instance.driverWithMostDrivesCount,
      'totalMoneyGenerated': instance.totalMoneyGenerated,
      'cityWithMostUsers': instance.cityWithMostUsers,
      'cityWithMostUsersCount': instance.cityWithMostUsersCount,
      'cityWithMostDrivers': instance.cityWithMostDrivers,
      'cityWithMostDriversCount': instance.cityWithMostDriversCount,
      'brandWithMostVehicles': instance.brandWithMostVehicles,
      'brandWithMostVehiclesCount': instance.brandWithMostVehiclesCount,
    };
