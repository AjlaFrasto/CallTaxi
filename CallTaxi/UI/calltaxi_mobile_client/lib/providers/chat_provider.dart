import 'package:calltaxi_mobile_client/model/chat.dart';
import 'package:calltaxi_mobile_client/providers/base_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatProvider extends BaseProvider<Chat> {
  ChatProvider() : super("Chat");

  @override
  Chat fromJson(dynamic json) {
    return Chat.fromJson(json);
  }

  Future<bool> markConversationAsRead(int senderId, int receiverId) async {
    try {
      var url =
          "${BaseProvider.baseUrl}Chat/mark-conversation-read?senderId=$senderId&receiverId=$receiverId";
      var uri = Uri.parse(url);
      var headers = createHeaders();

      var response = await http.post(uri, headers: headers);

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Error marking conversation as read: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Exception marking conversation as read: $e");
      return false;
    }
  }
}
