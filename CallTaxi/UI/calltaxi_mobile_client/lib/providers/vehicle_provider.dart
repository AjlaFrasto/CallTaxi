import 'package:calltaxi_mobile_client/model/vehicle.dart';
import 'package:calltaxi_mobile_client/providers/base_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VehicleProvider extends BaseProvider<Vehicle> {
  VehicleProvider() : super("Vehicle");

  @override
  Vehicle fromJson(dynamic json) {
    return Vehicle.fromJson(json);
  }

  Future<Vehicle> accept(int id) async {
    var url = "${BaseProvider.baseUrl}${endpoint}/$id/accept";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.put(uri, headers: headers);
    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return Vehicle.fromJson(data);
    } else {
      throw Exception("Unknown error");
    }
  }

  Future<Vehicle> reject(int id) async {
    var url = "${BaseProvider.baseUrl}${endpoint}/$id/reject";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.put(uri, headers: headers);
    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return Vehicle.fromJson(data);
    } else {
      throw Exception("Unknown error");
    }
  }
}
