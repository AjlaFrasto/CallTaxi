import 'dart:convert';

import 'package:calltaxi_desktop_admin/model/city.dart';
import 'package:calltaxi_desktop_admin/model/search_result.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:calltaxi_desktop_admin/providers/auth_provider.dart';

class CityProvider extends ChangeNotifier {
  static String? _baseUrl;
  CityProvider() {
    _baseUrl = const String.fromEnvironment(
      "baseUrl",
      defaultValue: "http://localhost:5130",
    );
  }

  Future<SearchResult<City>> get({dynamic filter}) async {
    var url = "$_baseUrl/City";
    print("filter: $filter");
    if (filter != null) {
      var query = getQueryString(filter);
      print("query: $query");
      url += "?$query";
    }
    print("url: $url");
    var uri = Uri.parse(url);
    var response = await http.get(uri, headers: createHeaders());
    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);

      var searchResult = SearchResult<City>();

      searchResult.totalCount = data["totalCount"];
      searchResult.items = List<City>.from(
        data["items"].map((e) => City.fromJson(e)),
      );
      return searchResult;
    } else {
      throw Exception("Something went wrong, please try again later!");
    }
  }

  String getQueryString(
    Map params, {
    String prefix = '&',
    bool inRecursion = false,
  }) {
    String query = '';
    params.forEach((key, value) {
      if (inRecursion) {
        if (key is int) {
          key = '[$key]';
        } else if (value is List || value is Map) {
          key = '.$key';
        } else {
          key = '.$key';
        }
      }
      if (value is String || value is int || value is double || value is bool) {
        var encoded = value;
        if (value is String) {
          encoded = Uri.encodeComponent(value);
        }
        query += '$prefix$key=$encoded';
      } else if (value is DateTime) {
        query += '$prefix$key=${(value as DateTime).toIso8601String()}';
      } else if (value is List || value is Map) {
        if (value is List) value = value.asMap();
        value.forEach((k, v) {
          query += getQueryString(
            {k: v},
            prefix: '$prefix$key',
            inRecursion: true,
          );
        });
      }
    });
    return query;
  }

  bool isValidResponse(http.Response response) {
    if (response.statusCode <= 299) {
      return true;
    } else if (response.statusCode == 401) {
      throw Exception("Please check your credentials and try again.");
    } else {
      throw Exception("Something went wrong, please try again later!");
    }
  }

  Map<String, String> createHeaders() {
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('${AuthProvider.username}:${AuthProvider.password}'))}';
    var headers = {
      "Content-Type": "application/json",
      "Authorization": basicAuth,
    };
    return headers;
  }
}
