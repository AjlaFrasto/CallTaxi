import 'package:calltaxi_mobile_client/model/vehicle_tier.dart';
import 'package:calltaxi_mobile_client/providers/base_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VehicleTierProvider extends BaseProvider<VehicleTier> {
  VehicleTierProvider() : super("VehicleTier");

  @override
  VehicleTier fromJson(dynamic json) {
    return VehicleTier.fromJson(json);
  }

  /// Get recommended vehicle tier for a specific user
  Future<VehicleTier?> recommendForUser(int userId) async {
    try {
      var url = "${BaseProvider.baseUrl}$endpoint/recommend/$userId";
      var uri = Uri.parse(url);
      var headers = createHeaders();

      var response = await http.get(uri, headers: headers);

      if (isValidResponse(response)) {
        var data = jsonDecode(response.body);
        return fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error getting recommended tier: $e');
      return null;
    }
  }
}
