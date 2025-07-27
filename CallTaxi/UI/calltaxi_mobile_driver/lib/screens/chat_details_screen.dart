import 'package:flutter/material.dart';
import 'package:calltaxi_mobile_driver/model/chat.dart';
import 'package:calltaxi_mobile_driver/model/search_result.dart';
import 'package:calltaxi_mobile_driver/providers/chat_provider.dart';
import 'package:calltaxi_mobile_driver/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class ChatDetailsScreen extends StatefulWidget {
  final int otherPersonId;
  final String otherPersonName;

  const ChatDetailsScreen({
    super.key,
    required this.otherPersonId,
    required this.otherPersonName,
  });

  @override
  State<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends State<ChatDetailsScreen> {
  late ChatProvider chatProvider;
  late TextEditingController _messageController;
  late ScrollController _scrollController;
  SearchResult<Chat>? messages;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      chatProvider = Provider.of<ChatProvider>(context, listen: false);
      await _loadMessages();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    if (UserProvider.currentUser == null) {
      print("No current user found");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get messages where current user is sender OR receiver
      var filter = {
        "page": 0,
        "pageSize": 100,
        "includeTotalCount": true,
        "senderId": UserProvider.currentUser!.id,
        "receiverId": widget.otherPersonId,
      };

      var result = await chatProvider.getOptimized(filter: filter);

      // Also get messages where current user is receiver and other person is sender
      var filter2 = {
        "page": 0,
        "pageSize": 100,
        "includeTotalCount": true,
        "senderId": widget.otherPersonId,
        "receiverId": UserProvider.currentUser!.id,
      };

      var result2 = await chatProvider.getOptimized(filter: filter2);

      // Combine both results and sort by creation time
      var allMessages = <Chat>[];
      if (result.items != null) allMessages.addAll(result.items!);
      if (result2.items != null) allMessages.addAll(result2.items!);

      // Sort by creation time (oldest first)
      allMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      setState(() {
        messages = SearchResult<Chat>()
          ..items = allMessages
          ..totalCount = allMessages.length;
        _isLoading = false;
      });

      // Mark conversation as read when opening chat
      await _markConversationAsRead();

      // Add a small delay to ensure backend processes the read status
      await Future.delayed(Duration(milliseconds: 500));

      // Scroll to bottom after loading
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      print("Error loading messages: $e");
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error loading messages: $e")));
    }
  }

  Future<void> _markConversationAsRead() async {
    try {
      print(
        "Marking conversation as read: ${widget.otherPersonId} -> ${UserProvider.currentUser!.id}",
      );
      // Mark messages from other person to current user as read
      await chatProvider.markConversationAsRead(
        widget.otherPersonId,
        UserProvider.currentUser!.id,
      );
      print("Successfully marked conversation as read");
    } catch (e) {
      print("Error marking conversation as read: $e");
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    try {
      var request = {
        'senderId': UserProvider.currentUser!.id,
        'receiverId': widget.otherPersonId,
        'message': _messageController.text.trim(),
      };

      await chatProvider.insert(request);
      _messageController.clear();

      // Reload messages to show the new message
      await _loadMessages();
    } catch (e) {
      print("Error sending message: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error sending message: $e")));
    }
  }

  Widget _buildMessageBubble(Chat message) {
    bool isMe = message.senderId == UserProvider.currentUser!.id;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? Colors.lightBlue : Colors.grey[200],
          borderRadius: BorderRadius.circular(18),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.message,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 4),
            Text(
              _formatTime(message.createdAt),
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherPersonName),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : messages == null || messages!.items?.isEmpty == true
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          "No messages yet",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Start a conversation!",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadMessages,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.only(top: 8, bottom: 8),
                      physics: AlwaysScrollableScrollPhysics(),
                      itemCount: messages!.items?.length ?? 0,
                      itemBuilder: (context, index) {
                        return _buildMessageBubble(messages!.items![index]);
                      },
                    ),
                  ),
          ),
          // Message input
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFFF6F00),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
