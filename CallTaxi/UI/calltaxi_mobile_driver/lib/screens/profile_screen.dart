import 'dart:convert';
import 'dart:typed_data';
import 'package:calltaxi_mobile_driver/providers/user_provider.dart';
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 24),
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.orange.shade100,
              backgroundImage:
                  (user.picture != null && user.picture!.isNotEmpty)
                  ? getUserImageProvider(user.picture)
                  : null,
              child: user.picture == null || user.picture!.isEmpty
                  ? Icon(Icons.account_circle, size: 100, color: Colors.orange)
                  : null,
            ),
            SizedBox(height: 18),
            Text(
              '${user.firstName} ${user.lastName}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              '@${user.username}',
              style: TextStyle(fontSize: 16, color: Colors.blueGrey[700]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 18),
            _buildInfoRow(Icons.email, 'Email', user.email),
            _buildInfoRow(Icons.phone, 'Phone', user.phoneNumber ?? '-'),
            _buildInfoRow(Icons.person_outline, 'Gender', user.genderName),
            _buildInfoRow(Icons.location_city, 'City', user.cityName),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified_user, color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Text(
                  'Active:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(width: 8),
                Icon(
                  user.isActive ? Icons.check_circle : Icons.cancel,
                  color: user.isActive ? Colors.green : Colors.red,
                  size: 22,
                ),
              ],
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: Colors.orange),
          SizedBox(width: 8),
          Text(
            '$label:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
