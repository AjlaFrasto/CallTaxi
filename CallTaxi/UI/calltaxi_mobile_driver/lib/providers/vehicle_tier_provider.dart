import 'package:calltaxi_mobile_driver/model/vehicle_tier.dart';
import 'package:calltaxi_mobile_driver/providers/base_provider.dart';

class VehicleTierProvider extends BaseProvider<VehicleTier> {
  VehicleTierProvider() : super("VehicleTier");

  @override
  VehicleTier fromJson(dynamic json) {
    return VehicleTier.fromJson(json);
  }
}
