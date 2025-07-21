import 'package:json_annotation/json_annotation.dart';

part 'review.g.dart';

@JsonSerializable()
class Review {
  final int id;
  final int driveRequestId;
  final String? driverFullName;
  final int userId;
  final String? userFullName;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final String? startLocation;
  final String? endLocation;

  Review({
    this.id = 0,
    this.driveRequestId = 0,
    this.driverFullName,
    this.userId = 0,
    this.userFullName,
    this.rating = 0,
    this.comment,
    required this.createdAt,
    this.startLocation,
    this.endLocation,
  });

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewToJson(this);
}
