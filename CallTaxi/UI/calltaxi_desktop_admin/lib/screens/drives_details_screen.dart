import 'package:calltaxi_desktop_admin/layouts/master_screen.dart';
import 'package:calltaxi_desktop_admin/model/driver_request.dart';
import 'package:flutter/material.dart';
import '../utils/custom_map_view.dart';

class DrivesDetailsScreen extends StatelessWidget {
  final DriverRequest drive;
  const DrivesDetailsScreen({super.key, required this.drive});

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
      title: "Drive Details",
      showBackButton: true,
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 1000),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 24.0,
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Map on the left
                    SizedBox(
                      width: 420,
                      child: CustomMapView(
                        start: drive.startLocation,
                        end: drive.endLocation,
                        height: 400,
                        width: 420,
                      ),
                    ),
                    SizedBox(width: 32),
                    // Details on the right
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 400,
                            minHeight: 0,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildInfoRow(
                                "Drive Number",
                                drive.id.toString(),
                                icon: Icons.confirmation_number,
                              ),
                              _buildInfoRow(
                                "User",
                                drive.userFullName ?? '-',
                                icon: Icons.person,
                              ),
                              _buildInfoRow(
                                "Driver",
                                drive.driverFullName ?? '-',
                                icon: Icons.drive_eta,
                              ),
                              _buildInfoRow(
                                "Vehicle",
                                drive.vehicleName ?? '-',
                                icon: Icons.directions_car,
                              ),
                              _buildInfoRow(
                                "Vehicle Tier",
                                drive.vehicleTierName ?? '-',
                                icon: Icons.star,
                              ),
                              _buildInfoRow(
                                "License Plate",
                                drive.vehicleLicensePlate ?? '-',
                                icon: Icons.credit_card,
                              ),
                              _buildInfoRow(
                                "Final Price",
                                "${drive.finalPrice.toStringAsFixed(2)} KM",
                                icon: Icons.attach_money,
                              ),
                              _buildInfoRow(
                                "Base Price",
                                "${drive.basePrice.toStringAsFixed(2)} KM",
                                icon: Icons.money,
                              ),
                              _buildInfoRow(
                                "Status",
                                drive.statusName ?? '-',
                                icon: Icons.info,
                              ),
                              _buildInfoRow(
                                "Created At",
                                drive.createdAt.toString().split(' ')[0],
                                icon: Icons.calendar_today,
                              ),
                              if (drive.acceptedAt != null)
                                _buildInfoRow(
                                  "Accepted At",
                                  drive.acceptedAt.toString().split(' ')[0],
                                  icon: Icons.calendar_today,
                                ),
                              if (drive.completedAt != null)
                                _buildInfoRow(
                                  "Completed At",
                                  drive.completedAt.toString().split(' ')[0],
                                  icon: Icons.calendar_today,
                                ),
                              _buildInfoRow(
                                "Start Location",
                                drive.startLocation ?? '-',
                                icon: Icons.location_on,
                              ),
                              _buildInfoRow(
                                "End Location",
                                drive.endLocation ?? '-',
                                icon: Icons.flag,
                              ),
                            ],
                          ),
                        ),
                      ),
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
