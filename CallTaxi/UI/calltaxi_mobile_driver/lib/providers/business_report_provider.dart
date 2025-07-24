import 'package:calltaxi_desktop_admin/model/business_report.dart';
import 'package:calltaxi_desktop_admin/providers/base_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BusinessReportProvider extends BaseProvider<BusinessReport> {
  BusinessReportProvider() : super("BusinessReport");

  @override
  BusinessReport fromJson(dynamic json) {
    return BusinessReport.fromJson(json);
  }

  Future<BusinessReport> fetchReport() async {
    var url = "${BaseProvider.baseUrl}${endpoint}";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.get(uri, headers: headers);
    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return BusinessReport.fromJson(data);
    } else {
      throw Exception("Unknown error");
    }
  }
}
