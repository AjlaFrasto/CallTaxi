import 'package:calltaxi_desktop_admin/layouts/master_screen.dart';
import 'package:calltaxi_desktop_admin/model/review.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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
          constraints: BoxConstraints(maxWidth: 500),
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  SizedBox(height: 18),
                  Center(child: _buildStarRating(review.rating)),
                  SizedBox(height: 18),
                  Text(
                    "Comment",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange, width: 1),
                    ),
                    constraints: BoxConstraints(minHeight: 80),
                    child: Text(
                      review.comment ?? '-',
                      style: TextStyle(fontSize: 16),
                      softWrap: true,
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    "Route",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  _ReviewMapWithZoom(
                    start: review.startLocation,
                    end: review.endLocation,
                  ),
                  SizedBox(height: 18),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Reviewed on: ${review.createdAt.toString().split(' ')[0]}",
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
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

class _ReviewMapWithZoom extends StatefulWidget {
  final String? start;
  final String? end;
  const _ReviewMapWithZoom({this.start, this.end});

  @override
  State<_ReviewMapWithZoom> createState() => _ReviewMapWithZoomState();
}

class _ReviewMapWithZoomState extends State<_ReviewMapWithZoom> {
  late final MapController _mapController;
  double _zoom = 13;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    LatLng? startLatLng;
    LatLng? endLatLng;
    String? error;
    try {
      if (widget.start != null && widget.end != null) {
        final startParts = widget.start!.split(',');
        final endParts = widget.end!.split(',');
        if (startParts.length == 2 && endParts.length == 2) {
          startLatLng = LatLng(
            double.parse(startParts[0]),
            double.parse(startParts[1]),
          );
          endLatLng = LatLng(
            double.parse(endParts[0]),
            double.parse(endParts[1]),
          );
        } else {
          error = 'Invalid location format.';
        }
      } else {
        error = 'Location not available.';
      }
    } catch (e) {
      error = 'Failed to parse locations.';
    }
    if (error != null) {
      return Container(
        height: 250,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange, width: 1),
        ),
        child: Center(
          child: Text(error, style: TextStyle(color: Colors.red)),
        ),
      );
    }
    final LatLng center = startLatLng != null && endLatLng != null
        ? LatLng(
            (startLatLng.latitude + endLatLng.latitude) / 2,
            (startLatLng.longitude + endLatLng.longitude) / 2,
          )
        : (startLatLng ?? LatLng(0, 0));
    return SizedBox(
      height: 250,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: center,
                initialZoom: _zoom,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                ),
                onPositionChanged: (pos, hasGesture) {
                  setState(() {
                    _zoom = pos.zoom ?? _zoom;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.calltaxi_desktop_admin',
                ),
                if (startLatLng != null && endLatLng != null)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: [startLatLng, endLatLng],
                        color: Colors.blue,
                        strokeWidth: 4.0,
                      ),
                    ],
                  ),
                if (startLatLng != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: startLatLng,
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.location_on,
                          color: Colors.green,
                          size: 32,
                        ),
                      ),
                      if (endLatLng != null)
                        Marker(
                          point: endLatLng,
                          width: 40,
                          height: 40,
                          child: Icon(Icons.flag, color: Colors.red, size: 32),
                        ),
                    ],
                  ),
              ],
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Column(
              children: [
                FloatingActionButton(
                  mini: true,
                  heroTag: 'zoomIn',
                  onPressed: () {
                    setState(() {
                      _zoom += 1;
                      _mapController.move(_mapController.center, _zoom);
                    });
                  },
                  child: Icon(Icons.add),
                ),
                SizedBox(height: 8),
                FloatingActionButton(
                  mini: true,
                  heroTag: 'zoomOut',
                  onPressed: () {
                    setState(() {
                      _zoom -= 1;
                      _mapController.move(_mapController.center, _zoom);
                    });
                  },
                  child: Icon(Icons.remove),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
