import 'dart:convert';
import 'dart:typed_data';
import 'package:calltaxi_mobile_client/providers/user_provider.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Helper for base64 image handling
  static ImageProvider? getUserImageProvider(String? picture) {
    if (picture == null || picture.isEmpty) {
      return null;
    }
    try {
      Uint8List bytes = base64Decode(picture);
      return MemoryImage(bytes);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = UserProvider.currentUser;
    if (user == null) {
      return Center(child: Text('No user data available'));
    }
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Color(0xFFF7F7F7),
      body: Stack(
        children: [
          // Gradient header
          Image.asset(
            'assets/images/profile_header.png',
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          // Main content
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 10),
                // Avatar with border and shadow
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 16,
                          offset: Offset(0, 8),
                        ),
                      ],
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.orange.shade100,
                      backgroundImage:
                          (user.picture != null && user.picture!.isNotEmpty)
                          ? getUserImageProvider(user.picture)
                          : null,
                      child: user.picture == null || user.picture!.isEmpty
                          ? Icon(
                              Icons.account_circle,
                              size: 100,
                              color: Colors.orange,
                            )
                          : null,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // Card with profile info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 28,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '${user.firstName} ${user.lastName}',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF6F00),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 6),
                          Text(
                            '@${user.username}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 18),
                          Divider(),
                          _buildInfoTile(Icons.email, 'Email', user.email),
                          _buildInfoTile(
                            Icons.phone,
                            'Phone',
                            user.phoneNumber ?? '-',
                          ),
                          _buildInfoTile(
                            Icons.person_outline,
                            'Gender',
                            user.genderName,
                          ),
                          _buildInfoTile(
                            Icons.location_city,
                            'City',
                            user.cityName,
                          ),
                          Divider(),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.verified_user,
                                      color: Colors.orange,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Active:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(
                                      user.isActive
                                          ? Icons.check_circle
                                          : Icons.cancel,
                                      color: user.isActive
                                          ? Colors.green
                                          : Colors.red,
                                      size: 22,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 32),
                // Optionally, add an edit button or actions here
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return ListTile(
      dense: true,
      leading: Container(
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.all(8),
        child: Icon(icon, size: 22, color: Colors.orange),
      ),
      title: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
      subtitle: Text(value, style: TextStyle(fontSize: 15)),
      contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 2),
    );
  }
}
