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

    print("Attempting to authenticate at URL: $url");
    print("Request body: $body");

    try {
      final response = await http
          .post(uri, headers: headers, body: body)
          .timeout(
            Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                "Request timed out. Please check your network connection.",
              );
            },
          );

      print("Response status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        currentUser = User.fromJson(data);
        return currentUser;
      } else if (response.statusCode == 401) {
        print("Authentication failed: Invalid credentials");
        return null;
      } else {
        print("Authentication failed with status code: ${response.statusCode}");
        throw Exception(
          "Failed to authenticate user. Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      print("Exception during authentication: $e");
      if (e.toString().contains("SocketException") ||
          e.toString().contains("Connection refused")) {
        throw Exception(
          "Cannot connect to server. Please check:\n1. Your computer's IP address\n2. The server is running\n3. Both devices are on the same network",
        );
      }
      throw Exception("Authentication failed: $e");
    }
  }
}
