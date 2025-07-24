import 'package:calltaxi_mobile_driver/model/user.dart';
import 'package:calltaxi_mobile_driver/providers/base_provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserProvider extends BaseProvider<User> {
  UserProvider() : super("Users");

  static User? currentUser;

  @override
  User fromJson(dynamic json) {
    return User.fromJson(json);
  }

  Future<User?> authenticate(String username, String password) async {
    var url = "${BaseProvider.baseUrl}Users/authenticate";
    var uri = Uri.parse(url);
    var headers = {"Content-Type": "application/json"};
    var body = jsonEncode({"username": username, "password": password});

    final response = await http.post(uri, headers: headers, body: body);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      currentUser = User.fromJson(data);
      return currentUser;
    } else if (response.statusCode == 401) {
      return null;
    } else {
      throw Exception("Failed to authenticate user");
    }
  }
}
