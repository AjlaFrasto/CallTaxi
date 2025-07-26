import 'package:calltaxi_mobile_driver/model/chat.dart';
import 'package:calltaxi_mobile_driver/model/search_result.dart';
import 'package:calltaxi_mobile_driver/providers/base_provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatProvider extends BaseProvider<Chat> {
  ChatProvider() : super('Chat');

  @override
  Chat fromJson(data) {
    return Chat.fromJson(data);
  }

  Future<SearchResult<Chat>> getOptimized({dynamic filter}) async {
    var url = "${BaseProvider.baseUrl}Chat/optimized";

    if (filter != null) {
      var queryString = getQueryString(filter);
      url = "$url?$queryString";
    }

    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);

      var result = SearchResult<Chat>();

      result.totalCount = data['totalCount'];
      result.items = List<Chat>.from(data["items"].map((e) => fromJson(e)));

      return result;
    } else {
      throw new Exception("Unknown error");
    }
  }

  Future<void> markConversationAsRead(int senderId, int receiverId) async {
    try {
      var url = "${BaseProvider.baseUrl}$endpoint/mark-conversation-read";
      var uri = Uri.parse(url);
      var headers = createHeaders();

      var jsonRequest = jsonEncode({
        'senderId': senderId,
        'receiverId': receiverId,
      });

      var response = await http.post(uri, headers: headers, body: jsonRequest);

      if (!isValidResponse(response)) {
        throw Exception("Failed to mark conversation as read");
      }
    } catch (e) {
      print('Error marking conversation as read: $e');
      rethrow;
    }
  }
}
