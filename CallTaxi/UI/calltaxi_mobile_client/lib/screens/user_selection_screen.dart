import 'package:flutter/material.dart';
import 'package:calltaxi_mobile_client/model/user.dart';
import 'package:calltaxi_mobile_client/model/search_result.dart';
import 'package:calltaxi_mobile_client/providers/user_provider.dart';
import 'package:calltaxi_mobile_client/utils/text_field_decoration.dart';
import 'package:provider/provider.dart';
import 'package:calltaxi_mobile_client/screens/chat_details_screen.dart';
import 'package:calltaxi_mobile_client/providers/chat_provider.dart';
import 'dart:convert';

class UserSelectionScreen extends StatefulWidget {
  const UserSelectionScreen({super.key});

  @override
  State<UserSelectionScreen> createState() => _UserSelectionScreenState();
}

class _UserSelectionScreenState extends State<UserSelectionScreen> {
  late UserProvider userProvider;
  late ChatProvider chatProvider;
  TextEditingController searchController = TextEditingController();
  SearchResult<User>? users;
  bool _isLoading = false;
  String _searchText = '';

  Future<void> _performSearch() async {
    if (UserProvider.currentUser == null) {
      print("No current user found");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get drivers (roleId: 2)
      var filterDrivers = {
        "page": 0,
        "pageSize": 100,
        "includeTotalCount": true,
        "fts": _searchText,
        "roleId": 2,
      };

      var resultDrivers = await userProvider.get(filter: filterDrivers);

      // Get users (roleId: 3)
      var filterUsers = {
        "page": 0,
        "pageSize": 100,
        "includeTotalCount": true,
        "fts": _searchText,
        "roleId": 3,
      };

      var resultUsers = await userProvider.get(filter: filterUsers);

      // Combine both results and filter out current user
      var allUsers = <User>[];
      if (resultDrivers.items != null) allUsers.addAll(resultDrivers.items!);
      if (resultUsers.items != null) allUsers.addAll(resultUsers.items!);

      // Filter out the current user
      var filteredUsers = allUsers
          .where((user) => user.id != UserProvider.currentUser!.id)
          .toList();

      setState(() {
        users = SearchResult<User>()
          ..items = filteredUsers
          ..totalCount = filteredUsers.length;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching users: $e");
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error loading users: $e")));
    }
  }

  Future<void> _startConversation(User selectedUser) async {
    try {
      // Check if conversation already exists
      var filter = {
        "page": 0,
        "pageSize": 1,
        "includeTotalCount": true,
        "senderId": UserProvider.currentUser!.id,
        "receiverId": selectedUser.id,
      };

      var result = await chatProvider.get(filter: filter);

      // Navigate to chat details
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatDetailsScreen(
            otherPersonId: selectedUser.id,
            otherPersonName:
                "${selectedUser.firstName} ${selectedUser.lastName}",
          ),
        ),
      );
    } catch (e) {
      print("Error starting conversation: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error starting conversation: $e")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      userProvider = Provider.of<UserProvider>(context, listen: false);
      chatProvider = Provider.of<ChatProvider>(context, listen: false);
      await _performSearch();
    });
  }

  Widget _buildUserCard(User user) {
    // Create image provider for user picture
    ImageProvider? userImageProvider;
    if (user.picture != null && user.picture!.isNotEmpty) {
      try {
        userImageProvider = MemoryImage(base64Decode(user.picture!));
      } catch (e) {
        userImageProvider = null;
      }
    }

    // Determine user role
    String userRole = user.roles.any((role) => role.id == 2)
        ? "Driver"
        : "User";

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _startConversation(user),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // User avatar
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.orange.shade100,
                backgroundImage: userImageProvider,
                child: userImageProvider == null
                    ? Icon(Icons.person, color: Colors.orange, size: 35)
                    : null,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${user.firstName} ${user.lastName}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "@${user.username}",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: userRole == "Driver"
                            ? Colors.blue.shade100
                            : Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        userRole,
                        style: TextStyle(
                          fontSize: 12,
                          color: userRole == "Driver"
                              ? Colors.blue.shade800
                              : Colors.green.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chat_bubble_outline, color: Colors.orange, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New Conversation"),
        backgroundColor: Color(0xFFFF6F00),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: customTextFieldDecoration(
                "Search users",
                prefixIcon: Icons.search,
              ),
              onChanged: (value) {
                setState(() => _searchText = value);
                _performSearch();
              },
            ),
          ),
          // Users list
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : users == null || users!.items?.isEmpty == true
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          "No users found",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Try adjusting your search",
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
                      itemCount: users!.items?.length ?? 0,
                      itemBuilder: (context, index) {
                        return _buildUserCard(users!.items![index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
