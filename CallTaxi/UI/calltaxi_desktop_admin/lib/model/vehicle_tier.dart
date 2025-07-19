import 'package:json_annotation/json_annotation.dart';

part 'vehicle_tier.g.dart';

@JsonSerializable()
class VehicleTier {
  final int id;
  final String name;
  final String? description;

  VehicleTier({this.id = 0, this.name = '', this.description});

  factory VehicleTier.fromJson(Map<String, dynamic> json) =>
      _$VehicleTierFromJson(json);
  Map<String, dynamic> toJson() => _$VehicleTierToJson(this);
}
