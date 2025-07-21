import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CustomMapView extends StatefulWidget {
  final String? start;
  final String? end;
  final double height;
  final double width;
  final double borderRadius;
  final bool showRouteInfoOverlay;
  final bool showZoomControls;

  const CustomMapView({
    Key? key,
    required this.start,
    required this.end,
    required this.height,
    required this.width,
    this.borderRadius = 18,
    this.showRouteInfoOverlay = true,
    this.showZoomControls = true,
  }) : super(key: key);

  @override
  State<CustomMapView> createState() => _CustomMapViewState();
}

class _CustomMapViewState extends State<CustomMapView> {
  late final MapController _mapController;
  double _zoom = 13;
  List<LatLng>? _routePoints;
  bool _loadingRoute = false;
  String? _routeError;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _fetchRoute();
  }

  Future<void> _fetchRoute() async {
    LatLng? startLatLng;
    LatLng? endLatLng;
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
        }
      }
    } catch (e) {
      setState(() {
        _routeError = 'Failed to parse locations.';
      });
      return;
    }
    if (startLatLng == null || endLatLng == null) {
      setState(() {
        _routeError = 'Location not available.';
      });
      return;
    }
    setState(() {
      _loadingRoute = true;
      _routeError = null;
    });
    try {
      final apiKey = dotenv.env['OPENROUTESERVICE_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        setState(() {
          _routeError = 'API key not found.';
          _loadingRoute = false;
        });
        return;
      }
      final url = Uri.parse(
        'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apiKey&start=${startLatLng.longitude},${startLatLng.latitude}&end=${endLatLng.longitude},${endLatLng.latitude}',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final geometry = data['features'][0]['geometry'];
        if (geometry['type'] == 'LineString') {
          final coords = geometry['coordinates'] as List;
          final points = coords
              .map<LatLng>(
                (c) =>
                    LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()),
              )
              .toList();
          setState(() {
            _routePoints = points;
            _loadingRoute = false;
          });
        } else {
          setState(() {
            _routeError = 'Route geometry not found.';
            _loadingRoute = false;
          });
        }
      } else {
        setState(() {
          _routeError = 'Failed to fetch route (${response.statusCode})';
          _loadingRoute = false;
        });
      }
    } catch (e) {
      setState(() {
        _routeError = 'Error fetching route.';
        _loadingRoute = false;
      });
    }
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
      return Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          side: BorderSide(color: Colors.orange, width: 2),
        ),
        child: Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.15),
                blurRadius: 16,
                spreadRadius: 2,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(error, style: TextStyle(color: Colors.red)),
          ),
        ),
      );
    }
    final LatLng center = startLatLng != null && endLatLng != null
        ? LatLng(
            (startLatLng.latitude + endLatLng.latitude) / 2,
            (startLatLng.longitude + endLatLng.longitude) / 2,
          )
        : (startLatLng ?? LatLng(0, 0));
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        side: BorderSide(color: Colors.orange, width: 2),
      ),
      child: Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.15),
              blurRadius: 16,
              spreadRadius: 2,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Stack(
            children: [
              MouseRegion(
                cursor: _isDragging
                    ? SystemMouseCursors.grabbing
                    : SystemMouseCursors.grab,
                child: Listener(
                  onPointerDown: (_) => setState(() => _isDragging = true),
                  onPointerUp: (_) => setState(() => _isDragging = false),
                  onPointerCancel: (_) => setState(() => _isDragging = false),
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
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName:
                            'com.example.calltaxi_desktop_admin',
                      ),
                      if (_routePoints != null)
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: _routePoints!,
                              color: Colors.deepPurpleAccent,
                              strokeWidth: 5.0,
                              borderStrokeWidth: 8.0,
                              borderColor: Colors.white.withOpacity(0.7),
                            ),
                          ],
                        ),
                      if (startLatLng != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: startLatLng,
                              width: 44,
                              height: 44,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.4),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                            if (endLatLng != null)
                              Marker(
                                point: endLatLng,
                                width: 44,
                                height: 44,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.red.withOpacity(0.4),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.flag,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              if (widget.showRouteInfoOverlay)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.route, color: Colors.orange, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Route Preview",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (widget.showZoomControls)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Column(
                    children: [
                      Tooltip(
                        message: "Zoom In",
                        child: FloatingActionButton(
                          mini: true,
                          heroTag: 'zoomIn${widget.key ?? ''}',
                          backgroundColor: Colors.white,
                          onPressed: () {
                            setState(() {
                              _zoom += 1;
                              _mapController.move(_mapController.center, _zoom);
                            });
                          },
                          child: Icon(Icons.add, color: Colors.orange),
                        ),
                      ),
                      SizedBox(height: 8),
                      Tooltip(
                        message: "Zoom Out",
                        child: FloatingActionButton(
                          mini: true,
                          heroTag: 'zoomOut${widget.key ?? ''}',
                          backgroundColor: Colors.white,
                          onPressed: () {
                            setState(() {
                              _zoom -= 1;
                              _mapController.move(_mapController.center, _zoom);
                            });
                          },
                          child: Icon(Icons.remove, color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_routeError != null)
                Positioned.fill(
                  child: Container(
                    color: Colors.white.withOpacity(0.7),
                    child: Center(
                      child: Text(
                        _routeError!,
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
