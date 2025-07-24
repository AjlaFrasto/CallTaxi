import 'package:json_annotation/json_annotation.dart';

part 'role_response.g.dart';

@JsonSerializable()
class RoleResponse {
  final int id;
  final String name;
  final String description;
  final DateTime? createdAt;
  final bool isActive;

  RoleResponse({
    this.id = 0,
    this.name = '',
    this.description = '',
    this.createdAt,
    this.isActive = true,
  });

  factory RoleResponse.fromJson(Map<String, dynamic> json) =>
      _$RoleResponseFromJson(json);
  Map<String, dynamic> toJson() => _$RoleResponseToJson(this);
}
