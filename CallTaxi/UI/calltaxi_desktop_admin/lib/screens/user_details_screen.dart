import 'dart:convert';
import 'package:calltaxi_desktop_admin/layouts/master_screen.dart';
import 'package:calltaxi_desktop_admin/model/user.dart';
import 'package:flutter/material.dart';

class UserDetailsScreen extends StatelessWidget {
  final User user;
  const UserDetailsScreen({super.key, required this.user});

  Widget _buildPicture(String? pictureBase64) {
    if (pictureBase64 == null || pictureBase64.isEmpty) {
      return Icon(Icons.account_circle, size: 64, color: Colors.grey);
    }
    try {
      final bytes = base64Decode(pictureBase64);
      return CircleAvatar(backgroundImage: MemoryImage(bytes), radius: 32);
    } catch (e) {
      return Icon(Icons.account_circle, size: 64, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "User Details",
      showBackButton: true,
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 400),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPicture(user.picture),
                  SizedBox(height: 16),
                  Text(
                    "${user.firstName} ${user.lastName}",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(user.email, style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  Text(
                    "Username: ${user.username}",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Phone: ${user.phoneNumber ?? '-'}",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Gender: ${user.genderName}",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "City: ${user.cityName}",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Roles: ${user.roles.map((r) => r.name).join(", ")}",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Created At: ${user.createdAt.toString().split(" ")[0]}",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Last Login: ${user.lastLoginAt?.toString().split(" ")[0] ?? '-'}",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Active: ", style: TextStyle(fontSize: 16)),
                      Icon(
                        user.isActive ? Icons.check : Icons.close,
                        color: user.isActive ? Colors.green : Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
