import 'package:json_annotation/json_annotation.dart';
import 'user.dart';
import 'city.dart';
import 'brand.dart';

part 'business_report.g.dart';

@JsonSerializable()
class BusinessReport {
  final User? driverWithHighestReviews;
  final double? bestDriverAverageRating;
  final User? userWithMostDrives;
  final int? userWithMostDrivesCount;
  final User? driverWithMostDrives;
  final int? driverWithMostDrivesCount;
  final double totalMoneyGenerated;
  final City? cityWithMostUsers;
  final int? cityWithMostUsersCount;
  final City? cityWithMostDrivers;
  final int? cityWithMostDriversCount;
  final Brand? brandWithMostVehicles;
  final int? brandWithMostVehiclesCount;

  BusinessReport({
    this.driverWithHighestReviews,
    this.bestDriverAverageRating,
    this.userWithMostDrives,
    this.userWithMostDrivesCount,
    this.driverWithMostDrives,
    this.driverWithMostDrivesCount,
    this.totalMoneyGenerated = 0.0,
    this.cityWithMostUsers,
    this.cityWithMostUsersCount,
    this.cityWithMostDrivers,
    this.cityWithMostDriversCount,
    this.brandWithMostVehicles,
    this.brandWithMostVehiclesCount,
  });

  factory BusinessReport.fromJson(Map<String, dynamic> json) =>
      _$BusinessReportFromJson(json);
  Map<String, dynamic> toJson() => _$BusinessReportToJson(this);
}
