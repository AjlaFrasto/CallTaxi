import 'dart:convert';
import 'package:calltaxi_desktop_admin/layouts/master_screen.dart';
import 'package:calltaxi_desktop_admin/model/vehicle.dart';
import 'package:flutter/material.dart';
import 'package:calltaxi_desktop_admin/utils/custom_picture_design.dart';

class VehicleDetailsScreen extends StatelessWidget {
  final Vehicle vehicle;
  const VehicleDetailsScreen({super.key, required this.vehicle});

  Widget _buildInfoRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 22, color: Colors.orange),
            SizedBox(width: 10),
          ],
          Text(
            "$label:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 17),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double brandLogoSize = 40;
    const double carImageSize = 180;
    return MasterScreen(
      title: "Vehicle Details",
      showBackButton: true,
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(maxWidth: 700),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 36.0,
                  vertical: 36.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Brand logo in top left, car image centered and larger
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomPictureDesign(
                          base64: vehicle.brandLogo,
                          size: brandLogoSize,
                          fallbackIcon: Icons.branding_watermark,
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: CustomPictureDesign(
                              base64: vehicle.picture,
                              size: carImageSize,
                              fallbackIcon: Icons.directions_car,
                            ),
                          ),
                        ),
                        SizedBox(width: brandLogoSize), // for symmetry
                      ],
                    ),
                    SizedBox(height: 24),
                    // Brand name + vehicle name in one line
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          vehicle.brandName,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[800],
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          vehicle.name,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Divider(height: 36, thickness: 1.2),
                    // Details in two columns
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow(
                                "License Plate",
                                vehicle.licensePlate,
                                icon: Icons.confirmation_number,
                              ),
                              _buildInfoRow(
                                "Color",
                                vehicle.color,
                                icon: Icons.color_lens,
                              ),
                              _buildInfoRow(
                                "Year",
                                vehicle.yearOfManufacture.toString(),
                                icon: Icons.calendar_today,
                              ),
                              _buildInfoRow(
                                "Seats",
                                vehicle.seatsCount.toString(),
                                icon: Icons.event_seat,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow(
                                "Tier",
                                vehicle.vehicleTierName ?? '-',
                                icon: Icons.star,
                              ),
                              _buildInfoRow(
                                "Pet Friendly",
                                vehicle.petFriendly ? 'Yes' : 'No',
                                icon: Icons.pets,
                              ),
                              _buildInfoRow(
                                "State",
                                vehicle.stateMachine,
                                icon: Icons.info_outline,
                              ),
                              _buildInfoRow(
                                "Driver",
                                vehicle.userFullName ?? '-',
                                icon: Icons.person,
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
        ),
      ),
    );
  }
}
