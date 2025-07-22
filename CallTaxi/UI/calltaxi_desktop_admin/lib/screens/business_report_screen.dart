import 'package:calltaxi_desktop_admin/layouts/master_screen.dart';
import 'package:calltaxi_desktop_admin/model/business_report.dart';
import 'package:calltaxi_desktop_admin/providers/business_report_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class BusinessReportScreen extends StatelessWidget {
  const BusinessReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BusinessReportProvider>(
      context,
      listen: false,
    );
    return MasterScreen(
      title: "Business Report",
      child: FutureBuilder<BusinessReport>(
        future: provider.fetchReport(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading report'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data available'));
          }
          final report = snapshot.data!;
          return Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Business Analytics",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    // First row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildUserCard(
                          context,
                          title: "Driver with Most Drives",
                          user: report.driverWithMostDrives,
                          subtitle: report.driverWithMostDrivesCount != null
                              ? "Drives: ${report.driverWithMostDrivesCount}"
                              : null,
                        ),
                        SizedBox(width: 32),
                        _buildDriverReviewCard(
                          context,
                          user: report.driverWithHighestReviews,
                          avgRating: report.bestDriverAverageRating,
                        ),
                        SizedBox(width: 32),
                        _buildUserCard(
                          context,
                          title: "User with Most Drives",
                          user: report.userWithMostDrives,
                          subtitle: report.userWithMostDrivesCount != null
                              ? "Drives: ${report.userWithMostDrivesCount}"
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    // Second row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildCityCard(
                          context,
                          title: "City with Most Drivers",
                          city: report.cityWithMostDrivers,
                          count: report.cityWithMostDriversCount,
                          icon: Icons.directions_car,
                          label: "Drivers",
                        ),
                        SizedBox(width: 32),
                        _buildMoneyCard(report.totalMoneyGenerated),
                        SizedBox(width: 32),
                        _buildCityCard(
                          context,
                          title: "City with Most Users",
                          city: report.cityWithMostUsers,
                          count: report.cityWithMostUsersCount,
                          icon: Icons.person,
                          label: "Users",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserCard(
    BuildContext context, {
    required String title,
    dynamic user,
    String? subtitle,
  }) {
    return Card(
      elevation: 4,
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 38,
              backgroundImage: user?.picture != null && user.picture != ''
                  ? MemoryImage(base64Decode(user.picture!))
                  : null,
              child: user?.picture == null || user.picture == ''
                  ? Icon(Icons.person, size: 38)
                  : null,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              user != null ? "${user.firstName} ${user.lastName}" : "-",
              style: TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDriverReviewCard(
    BuildContext context, {
    dynamic user,
    double? avgRating,
  }) {
    return Card(
      elevation: 4,
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 38,
              backgroundImage: user?.picture != null && user.picture != ''
                  ? MemoryImage(base64Decode(user.picture!))
                  : null,
              child: user?.picture == null || user.picture == ''
                  ? Icon(Icons.person, size: 38)
                  : null,
            ),
            const SizedBox(height: 12),
            Text(
              "Driver with Highest Reviews",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              user != null ? "${user.firstName} ${user.lastName}" : "-",
              style: TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
            ),
            if (avgRating != null) ...[
              const SizedBox(height: 4),
              _buildStarRating(avgRating),
              Text(
                "Avg. Rating: ${avgRating.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    int fullStars = rating.floor();
    bool halfStar = (rating - fullStars) >= 0.5;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return Icon(Icons.star, color: Colors.amber, size: 20);
        } else if (index == fullStars && halfStar) {
          return Icon(Icons.star_half, color: Colors.amber, size: 20);
        } else {
          return Icon(Icons.star_border, color: Colors.amber, size: 20);
        }
      }),
    );
  }

  Widget _buildCityCard(
    BuildContext context, {
    required String title,
    dynamic city,
    int? count,
    required IconData icon,
    required String label,
  }) {
    return Card(
      elevation: 4,
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 38, color: Colors.orange),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              city != null ? city.name : "-",
              style: TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
            ),
            if (count != null) ...[
              const SizedBox(height: 4),
              Text(
                "$label: $count",
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMoneyCard(double money) {
    return Card(
      elevation: 4,
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.attach_money, size: 38, color: Colors.green[700]),
            const SizedBox(height: 12),
            Text(
              "Total Money Generated",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              "${money.toStringAsFixed(2)} KM",
              style: TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
