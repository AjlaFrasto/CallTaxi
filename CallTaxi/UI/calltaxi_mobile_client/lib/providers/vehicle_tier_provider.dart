import 'package:calltaxi_mobile_client/model/vehicle_tier.dart';
import 'package:calltaxi_mobile_client/providers/base_provider.dart';

class VehicleTierProvider extends BaseProvider<VehicleTier> {
  VehicleTierProvider() : super("VehicleTier");

  @override
  VehicleTier fromJson(dynamic json) {
    return VehicleTier.fromJson(json);
  }
}
