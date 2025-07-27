import 'package:flutter/material.dart';
import 'package:calltaxi_mobile_client/model/chat.dart';
import 'package:calltaxi_mobile_client/model/search_result.dart';
import 'package:calltaxi_mobile_client/providers/chat_provider.dart';
import 'package:calltaxi_mobile_client/providers/user_provider.dart';
import 'package:calltaxi_mobile_client/utils/text_field_decoration.dart';
import 'package:provider/provider.dart';
import 'package:calltaxi_mobile_client/screens/chat_details_screen.dart';
import 'package:calltaxi_mobile_client/screens/user_selection_screen.dart';
import 'dart:convert'; // Added for base64Decode

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late ChatProvider chatProvider;
  TextEditingController searchController = TextEditingController();
  SearchResult<Chat>? chats;
  bool _isLoading = false;
  String _searchText = '';

  Future<void> _performSearch() async {
    if (UserProvider.currentUser == null) {
      print("No current user found");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get messages where current user is sender
      var filter1 = {
        "page": 0,
        "pageSize": 100,
        "includeTotalCount": true,
        "fts": _searchText,
        "senderId": UserProvider.currentUser!.id,
      };

      var result1 = await chatProvider.get(filter: filter1);

      // Get messages where current user is receiver
      var filter2 = {
        "page": 0,
        "pageSize": 100,
        "includeTotalCount": true,
        "fts": _searchText,
        "receiverId": UserProvider.currentUser!.id,
      };

      var result2 = await chatProvider.get(filter: filter2);

      // Combine all messages
      var allMessages = <Chat>[];
      if (result1.items != null) allMessages.addAll(result1.items!);
      if (result2.items != null) allMessages.addAll(result2.items!);

      // Group messages by conversation partner
      Map<int, List<Chat>> conversations = {};

      for (var message in allMessages) {
        int otherPersonId;
        if (message.senderId == UserProvider.currentUser!.id) {
          otherPersonId = message.receiverId;
        } else {
          otherPersonId = message.senderId;
        }

        if (!conversations.containsKey(otherPersonId)) {
          conversations[otherPersonId] = [];
        }
        conversations[otherPersonId]!.add(message);
      }

      // Get the latest message for each conversation
      var latestMessages = <Chat>[];
      conversations.forEach((otherPersonId, messages) {
        // Sort by creation time and get the latest
        messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        latestMessages.add(messages.first);
      });

      // Sort conversations by latest message time
      latestMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      setState(() {
        chats = SearchResult<Chat>()
          ..items = latestMessages
          ..totalCount = latestMessages.length;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching chats: $e");
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error loading chats: $e")));
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      chatProvider = Provider.of<ChatProvider>(context, listen: false);
      await _performSearch();
    });
  }

  Widget _buildChatCard(Chat chat) {
    // Determine if current user is sender or receiver
    bool isSender = chat.senderId == UserProvider.currentUser!.id;
    String otherPersonName = isSender
        ? chat.receiverName ?? 'Unknown'
        : chat.senderName ?? 'Unknown';
    int otherPersonId = isSender ? chat.receiverId : chat.senderId;
    String? otherPersonPicture = isSender
        ? chat.receiverPicture
        : chat.senderPicture;

    // Check if this message is unread from current user's perspective
    bool isUnread = !isSender && !chat.isRead;

    // Create image provider for the other person's picture
    ImageProvider? profileImageProvider;
    if (otherPersonPicture != null && otherPersonPicture.isNotEmpty) {
      try {
        profileImageProvider = MemoryImage(base64Decode(otherPersonPicture));
      } catch (e) {
        profileImageProvider = null;
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDetailsScreen(
                otherPersonId: otherPersonId,
                otherPersonName: otherPersonName,
              ),
            ),
          ).then((_) {
            // Refresh chat list when returning from chat details
            // Add a small delay to ensure backend has processed read status
            Future.delayed(Duration(milliseconds: 300), () {
              _performSearch();
            });
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar with profile picture
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.orange.shade100,
                backgroundImage: profileImageProvider,
                child: profileImageProvider == null
                    ? Icon(Icons.person, color: Colors.orange, size: 30)
                    : null,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            otherPersonName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          _formatTime(chat.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chat.message,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.lightBlue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search bar and New Chat button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: customTextFieldDecoration(
                      "Search chats",
                      prefixIcon: Icons.search,
                    ),
                    onChanged: (value) {
                      setState(() => _searchText = value);
                      _performSearch();
                    },
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserSelectionScreen(),
                      ),
                    ).then((_) {
                      // Refresh chat list when returning from user selection
                      _performSearch();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "New Chat",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          // Chat list
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : chats == null || chats!.items?.isEmpty == true
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
                          "No chats found",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Your conversations will appear here",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _performSearch,
                    child: ListView.builder(
                      padding: EdgeInsets.only(bottom: 16),
                      itemCount: chats!.items?.length ?? 0,
                      itemBuilder: (context, index) {
                        return _buildChatCard(chats!.items![index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
