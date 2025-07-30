import 'package:flutter/material.dart';
import 'package:calltaxi_mobile_client/model/driver_request.dart';
import 'package:calltaxi_mobile_client/utils/custom_map_view.dart';

class DrivesDetailsScreen extends StatelessWidget {
  final DriverRequest drive;

  const DrivesDetailsScreen({super.key, required this.drive});

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildInfoCard(
    String title,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Drive Details'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 32),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Completed',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          'Your ride has been completed successfully',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Route Information with Map
            Text(
              'Route Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 12),
            CustomMapView(
              start: drive.startLocation,
              end: drive.endLocation,
              height: 300,
              width: double.infinity,
              borderRadius: 12,
              showRouteInfoOverlay: true,
              showZoomControls: true,
            ),
            SizedBox(height: 24),

            // Price information
            Text(
              'Payment Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 12),
            _buildInfoCard(
              'Final Price',
              '${drive.finalPrice.toStringAsFixed(2)} KM',
              Icons.attach_money,
              Colors.green,
            ),
            _buildInfoCard(
              'Base Price',
              '${drive.basePrice.toStringAsFixed(2)} KM',
              Icons.tag,
              Colors.blue,
            ),
            SizedBox(height: 24),

            // Trip information
            Text(
              'Trip Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 12),
            _buildInfoCard(
              'Distance',
              '${drive.distance.toStringAsFixed(1)} km',
              Icons.straighten,
              Colors.orange,
            ),
            _buildInfoCard(
              'Vehicle Tier',
              drive.vehicleTierName ?? 'Unknown',
              Icons.local_taxi,
              Colors.purple,
            ),
            SizedBox(height: 24),

            // Driver information
            if (drive.driverFullName != null) ...[
              Text(
                'Driver Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 12),
              _buildInfoCard(
                'Driver Name',
                drive.driverFullName!,
                Icons.person,
                Colors.indigo,
              ),
              if (drive.vehicleName != null)
                _buildInfoCard(
                  'Vehicle',
                  drive.vehicleName!,
                  Icons.directions_car,
                  Colors.teal,
                ),
              if (drive.vehicleLicensePlate != null)
                _buildInfoCard(
                  'License Plate',
                  drive.vehicleLicensePlate!,
                  Icons.confirmation_number,
                  Colors.amber,
                ),
              SizedBox(height: 24),
            ],

            // Timestamps
            Text(
              'Timeline',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 12),
            _buildInfoCard(
              'Request Created',
              _formatDateTime(drive.createdAt),
              Icons.schedule,
              Colors.grey,
            ),
            if (drive.acceptedAt != null)
              _buildInfoCard(
                'Accepted',
                _formatDateTime(drive.acceptedAt!),
                Icons.thumb_up,
                Colors.blue,
              ),
            if (drive.completedAt != null)
              _buildInfoCard(
                'Completed',
                _formatDateTime(drive.completedAt!),
                Icons.check_circle,
                Colors.green,
              ),
            SizedBox(height: 24),

            // Trip ID
            _buildInfoCard(
              'Trip ID',
              '#${drive.id.toString().padLeft(6, '0')}',
              Icons.confirmation_number,
              Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
