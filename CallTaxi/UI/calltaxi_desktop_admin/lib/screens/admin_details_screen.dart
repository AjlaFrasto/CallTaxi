import 'dart:convert';
import 'package:calltaxi_desktop_admin/layouts/master_screen.dart';
import 'package:calltaxi_desktop_admin/model/user.dart';
import 'package:flutter/material.dart';
import 'package:calltaxi_desktop_admin/utils/custom_picture_design.dart';

class AdminDetailsScreen extends StatelessWidget {
  final User user;
  const AdminDetailsScreen({super.key, required this.user});

  Widget _buildInfoRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: Colors.orange),
            SizedBox(width: 8),
          ],
          Text(
            "$label:",
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

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Admin Details",
      showBackButton: true,
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 420),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 32.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomPictureDesign(
                    base64: user.picture,
                    size: 140,
                    fallbackIcon: Icons.account_circle,
                  ),
                  SizedBox(height: 18),
                  Text(
                    "${user.firstName} ${user.lastName}",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "@${user.username}",
                    style: TextStyle(fontSize: 16, color: Colors.blueGrey[700]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 18),
                  _buildInfoRow("Email", user.email, icon: Icons.email),
                  _buildInfoRow(
                    "Phone",
                    user.phoneNumber ?? '-',
                    icon: Icons.phone,
                  ),
                  _buildInfoRow(
                    "Gender",
                    user.genderName,
                    icon: Icons.person_outline,
                  ),
                  _buildInfoRow(
                    "City",
                    user.cityName,
                    icon: Icons.location_city,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified_user,
                          size: 20,
                          color: Colors.orange,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Active:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          user.isActive ? Icons.check_circle : Icons.cancel,
                          color: user.isActive ? Colors.green : Colors.red,
                          size: 22,
                        ),
                      ],
                    ),
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
