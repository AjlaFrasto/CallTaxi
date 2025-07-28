import 'package:calltaxi_desktop_admin/layouts/master_screen.dart';
import 'package:calltaxi_desktop_admin/model/driver_request.dart';
import 'package:flutter/material.dart';
import '../utils/custom_map_view.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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

  Future<String> getShortPlaceNameFromString(String? coordString) async {
    if (coordString == null || !coordString.contains(','))
      return 'Unknown location';
    final parts = coordString.split(',');
    if (parts.length != 2) return 'Unknown location';
    try {
      final lat = double.parse(parts[0]);
      final lon = double.parse(parts[1]);
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lon',
      );
      final response = await http.get(
        url,
        headers: {'User-Agent': 'CallTaxiDesktopAdmin/1.0 (your@email.com)'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final address = data['address'];
        if (address == null) return 'Unknown location';

        // Try to get a place name (add more keys as needed)
        String place =
            address['attraction'] ??
            address['building'] ??
            address['amenity'] ??
            address['theatre'] ??
            address['hotel'] ??
            address['airport'] ??
            address['leisure'] ??
            address['name'] ??
            '';

        String street = '';
        if (address['road'] != null) street += address['road'];
        if (address['house_number'] != null)
          street += ' ${address['house_number']}';
        street = street.trim();

        String city =
            address['city'] ??
            address['town'] ??
            address['village'] ??
            address['suburb'] ??
            '';

        // Compose: [place], [street], [city]
        List<String> partsList = [];
        if (place.isNotEmpty) partsList.add(place);
        if (street.isNotEmpty) partsList.add(street);
        if (city.isNotEmpty) partsList.add(city);

        // Always extract the first part of display_name
        String? displayFirst;
        if (data['display_name'] != null) {
          displayFirst = data['display_name'].split(',').first.trim();
        }

        // If displayFirst is not already in the result, prepend it
        if (displayFirst != null &&
            displayFirst.isNotEmpty &&
            !partsList.any(
              (p) => p.toLowerCase() == displayFirst!.toLowerCase(),
            )) {
          partsList.insert(0, displayFirst);
        }

        if (partsList.isNotEmpty) {
          return partsList.join(', ');
        } else {
          return data['display_name'] ?? 'Unknown location';
        }
      }
      return 'Unknown location';
    } catch (_) {
      return 'Unknown location';
    }
  }

  String formatDateTime(DateTime date) {
    return DateFormat('dd.MM.yyyy HH:mm:ss').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Drive Details",
      showBackButton: true,
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 1300),
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
                        routeDistance: drive.distance,
                      ),
                    ),
                    SizedBox(width: 32),
                    // Details on the right (split into two columns)
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 800,
                            minHeight: 0,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Middle column
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
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
                                    // Start Location (reverse geocoded, more space)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6.0,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            size: 20,
                                            color: Colors.orange,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            "Start Location:",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: FutureBuilder<String>(
                                              future:
                                                  getShortPlaceNameFromString(
                                                    drive.startLocation,
                                                  ),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return Text('Loading...');
                                                } else if (snapshot.hasError) {
                                                  return Text(
                                                    'Unknown location',
                                                  );
                                                } else {
                                                  return Text(
                                                    snapshot.data ??
                                                        'Unknown location',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                    ),
                                                    softWrap: true,
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 32),
                              // Right column
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _buildInfoRow(
                                      "Base Price",
                                      "${drive.basePrice.toStringAsFixed(2)} KM",
                                      icon: Icons.money,
                                    ),
                                    _buildInfoRow(
                                      "Final Price",
                                      "${drive.finalPrice.toStringAsFixed(2)} KM",
                                      icon: Icons.attach_money,
                                    ),
                                    _buildInfoRow(
                                      "Status",
                                      drive.statusName ?? '-',
                                      icon: Icons.info,
                                    ),
                                    _buildInfoRow(
                                      "Created At",
                                      formatDateTime(drive.createdAt),
                                      icon: Icons.calendar_today,
                                    ),
                                    if (drive.acceptedAt != null)
                                      _buildInfoRow(
                                        "Accepted At",
                                        formatDateTime(drive.acceptedAt!),
                                        icon: Icons.calendar_today,
                                      ),
                                    if (drive.completedAt != null)
                                      _buildInfoRow(
                                        "Completed At",
                                        formatDateTime(drive.completedAt!),
                                        icon: Icons.calendar_today,
                                      ),
                                    // End Location (reverse geocoded, more space)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6.0,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.flag,
                                            size: 20,
                                            color: Colors.orange,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            "End Location:",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: FutureBuilder<String>(
                                              future:
                                                  getShortPlaceNameFromString(
                                                    drive.endLocation,
                                                  ),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return Text('Loading...');
                                                } else if (snapshot.hasError) {
                                                  return Text(
                                                    'Unknown location',
                                                  );
                                                } else {
                                                  return Text(
                                                    snapshot.data ??
                                                        'Unknown location',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                    ),
                                                    softWrap: true,
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
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
