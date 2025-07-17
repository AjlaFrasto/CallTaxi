import 'package:json_annotation/json_annotation.dart';
import 'role_response.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String username;
  final String? picture; // Will be base64 string from backend
  final bool isActive;
  final String? phoneNumber;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final int genderId;
  final String genderName;
  final int cityId;
  final String cityName;
  final List<RoleResponse> roles;

  User({
    this.id = 0,
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.username = '',
    this.picture,
    this.isActive = true,
    this.phoneNumber,
    required this.createdAt,
    this.lastLoginAt,
    this.genderId = 0,
    this.genderName = '',
    this.cityId = 0,
    this.cityName = '',
    this.roles = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
