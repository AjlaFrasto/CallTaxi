import 'package:calltaxi_desktop_admin/layouts/master_screen.dart';
import 'package:calltaxi_desktop_admin/model/review.dart';
import 'package:flutter/material.dart';
import '../utils/custom_map_view.dart';
import 'package:calltaxi_desktop_admin/screens/drives_details_screen.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
      List<String> partsList = [];
      if (place.isNotEmpty) partsList.add(place);
      if (street.isNotEmpty) partsList.add(street);
      if (city.isNotEmpty) partsList.add(city);
      String? displayFirst;
      if (data['display_name'] != null) {
        displayFirst = data['display_name'].split(',').first.trim();
      }
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

class ReviewDetailsScreen extends StatelessWidget {
  final Review review;
  const ReviewDetailsScreen({super.key, required this.review});

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

  Widget _buildStarRating(int rating) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 22,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Review Details",
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
                        start: review.startLocation,
                        end: review.endLocation,
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: _buildInfoRow(
                                      "User",
                                      review.userFullName ?? '-',
                                      icon: Icons.person,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: _buildInfoRow(
                                      "Driver",
                                      review.driverFullName ?? '-',
                                      icon: Icons.drive_eta,
                                    ),
                                  ),
                                ],
                              ),
                              // Start Location (reverse geocoded)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6.0,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                        future: getShortPlaceNameFromString(
                                          review.startLocation,
                                        ),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Text('Loading...');
                                          } else if (snapshot.hasError) {
                                            return Text('Unknown location');
                                          } else {
                                            return Text(
                                              snapshot.data ??
                                                  'Unknown location',
                                              style: TextStyle(fontSize: 15),
                                              softWrap: true,
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // End Location (reverse geocoded)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6.0,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                        future: getShortPlaceNameFromString(
                                          review.endLocation,
                                        ),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Text('Loading...');
                                          } else if (snapshot.hasError) {
                                            return Text('Unknown location');
                                          } else {
                                            return Text(
                                              snapshot.data ??
                                                  'Unknown location',
                                              style: TextStyle(fontSize: 15),
                                              softWrap: true,
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16),
                              Center(child: _buildStarRating(review.rating)),
                              SizedBox(height: 16),
                              Text(
                                "Comment",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 8),
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.orange,
                                    width: 1,
                                  ),
                                ),
                                constraints: BoxConstraints(minHeight: 60),
                                child: Text(
                                  review.comment ?? '-',
                                  style: TextStyle(fontSize: 15),
                                  softWrap: true,
                                ),
                              ),
                              SizedBox(height: 18),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  "Reviewed on: ${review.createdAt.toString().split(' ')[0]}",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
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
