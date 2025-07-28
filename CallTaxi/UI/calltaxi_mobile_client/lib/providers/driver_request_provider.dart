import 'package:calltaxi_mobile_client/model/driver_request.dart';
import 'package:calltaxi_mobile_client/providers/base_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DriverRequestProvider extends BaseProvider<DriverRequest> {
  DriverRequestProvider() : super("DriveRequest");

  @override
  DriverRequest fromJson(dynamic json) {
    return DriverRequest.fromJson(json);
  }

  Future<DriverRequest> accept(int id, int driverId, int vehicleId) async {
    var url = "${BaseProvider.baseUrl}${endpoint}/$id/accept";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    var body = jsonEncode({"driverId": driverId, "vehicleId": vehicleId});
    var response = await http.post(uri, headers: headers, body: body);
    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return DriverRequest.fromJson(data);
    } else {
      throw Exception("Unknown error");
    }
  }

  Future<DriverRequest> complete(int id) async {
    var url = "${BaseProvider.baseUrl}${endpoint}/$id/complete";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.post(uri, headers: headers);
    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return DriverRequest.fromJson(data);
    } else {
      throw Exception("Unknown error");
    }
  }

  Future<DriverRequest> cancel(int id) async {
    var url = "${BaseProvider.baseUrl}${endpoint}/$id/cancel";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.post(uri, headers: headers);
    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return DriverRequest.fromJson(data);
    } else {
      throw Exception("Unknown error");
    }
  }

  Future<DriverRequest> pay(int id) async {
    var url = "${BaseProvider.baseUrl}${endpoint}/$id/pay";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.post(uri, headers: headers);
    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return DriverRequest.fromJson(data);
    } else {
      throw Exception("Unknown error");
    }
  }
}
