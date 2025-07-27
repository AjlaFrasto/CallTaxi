import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CustomMapViewWithSelection extends StatefulWidget {
  final double height;
  final double width;
  final double borderRadius;
  final Function(String?)? onStartSelected;
  final Function(String?)? onEndSelected;
  final Function(double?)? onDistanceChanged; // NEW
  final bool showRouteInfoOverlay;
  final bool showZoomControls;

  const CustomMapViewWithSelection({
    Key? key,
    required this.height,
    required this.width,
    this.borderRadius = 18,
    this.onStartSelected,
    this.onEndSelected,
    this.onDistanceChanged, // NEW
    this.showRouteInfoOverlay = true,
    this.showZoomControls = true,
  }) : super(key: key);

  @override
  State<CustomMapViewWithSelection> createState() =>
      _CustomMapViewWithSelectionState();
}

class _CustomMapViewWithSelectionState
    extends State<CustomMapViewWithSelection> {
  late final MapController _mapController;
  double _zoom = 13;
  LatLng? _startLatLng;
  LatLng? _endLatLng;
  List<LatLng>? _routePoints;
  double? _distanceKm;
  bool _loadingRoute = false;
  String? _routeError;
  bool _isDragging = false;
  bool _selectingStart = true;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  Future<void> _fetchRouteAndDistance() async {
    if (_startLatLng == null || _endLatLng == null) return;
    setState(() {
      _loadingRoute = true;
      _routeError = null;
      _distanceKm = null;
    });
    try {
      final apiKey = dotenv.env['OPENROUTESERVICE_API_KEY'];
      print('OpenRouteService API Key: ' + (apiKey ?? 'NULL'));
      if (apiKey == null || apiKey.isEmpty) {
        setState(() {
          _routeError = 'API key not found.';
          _loadingRoute = false;
        });
        return;
      }
      final url = Uri.parse(
        'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apiKey&start=${_startLatLng!.longitude},${_startLatLng!.latitude}&end=${_endLatLng!.longitude},${_endLatLng!.latitude}',
      );
      print('Route API URL: ' + url.toString());
      final response = await http.get(url);
      print('Route API Response: ${response.statusCode} ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final geometry = data['features'][0]['geometry'];
        final summary = data['features'][0]['properties']['summary'];
        if (geometry['type'] == 'LineString') {
          final coords = geometry['coordinates'] as List;
          final points = coords
              .map<LatLng>(
                (c) =>
                    LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()),
              )
              .toList();
          final distance = (summary['distance'] as num).toDouble() / 1000.0;
          setState(() {
            _routePoints = points;
            _distanceKm = distance;
            _loadingRoute = false;
          });
          if (widget.onDistanceChanged != null) {
            widget.onDistanceChanged!(distance);
          }
        } else {
          setState(() {
            _routeError = 'Route geometry not found.';
            _loadingRoute = false;
          });
          if (widget.onDistanceChanged != null) {
            widget.onDistanceChanged!(null);
          }
        }
      } else {
        setState(() {
          _routeError = 'Failed to fetch route (${response.statusCode})';
          _loadingRoute = false;
        });
        if (widget.onDistanceChanged != null) {
          widget.onDistanceChanged!(null);
        }
      }
    } catch (e) {
      setState(() {
        _routeError = 'Error fetching route.';
        _loadingRoute = false;
      });
      if (widget.onDistanceChanged != null) {
        widget.onDistanceChanged!(null);
      }
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng latlng) {
    setState(() {
      if (_selectingStart) {
        _startLatLng = latlng;
        _endLatLng = null;
        _routePoints = null;
        _distanceKm = null;
        if (widget.onStartSelected != null) {
          widget.onStartSelected!("${latlng.latitude},${latlng.longitude}");
        }
        _selectingStart = false;
      } else {
        _endLatLng = latlng;
        if (widget.onEndSelected != null) {
          widget.onEndSelected!("${latlng.latitude},${latlng.longitude}");
        }
        _selectingStart = true;
        _fetchRouteAndDistance();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final LatLng center =
        _startLatLng ?? LatLng(43.8563, 18.4131); // Default: Sarajevo
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
                      onTap: _onMapTap,
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
                            'com.example.calltaxi_mobile_client',
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
                      MarkerLayer(
                        markers: [
                          if (_startLatLng != null)
                            Marker(
                              point: _startLatLng!,
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
                          if (_endLatLng != null)
                            Marker(
                              point: _endLatLng!,
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
              if (widget.showRouteInfoOverlay && _distanceKm != null)
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
                          "Distance: ${_distanceKm!.toStringAsFixed(2)} km",
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
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _selectingStart
                        ? "Tap on the map to select START location"
                        : "Tap on the map to select END location",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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
