import 'package:calltaxi_mobile_client/utils/custom_map_view_with_selection.dart';
import 'package:calltaxi_mobile_client/providers/vehicle_tier_provider.dart';
import 'package:calltaxi_mobile_client/providers/driver_request_provider.dart';
import 'package:calltaxi_mobile_client/model/vehicle_tier.dart';
import 'package:calltaxi_mobile_client/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calltaxi_mobile_client/model/driver_request.dart';

class CallTaxiScreen extends StatefulWidget {
  const CallTaxiScreen({Key? key}) : super(key: key);

  @override
  State<CallTaxiScreen> createState() => _CallTaxiScreenState();
}

class _CallTaxiScreenState extends State<CallTaxiScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _showForm = false;
  bool _waitingForDriver = false;
  String? _startLocation;
  String? _endLocation;
  double? _distanceKm;
  int? _selectedTierId;
  double? _basePrice;
  double? _finalPrice;
  List<VehicleTier> _tiers = [];
  bool _loadingTiers = true;
  bool _submitting = false;
  String? _error;
  DriverRequest? _pendingDrive;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
    _fetchTiers();
    _checkPendingDrive();
  }

  Future<void> _fetchTiers() async {
    setState(() => _loadingTiers = true);
    final provider = VehicleTierProvider();
    final result = await provider.get();
    final tiers = result.items ?? [];
    int? defaultTierId;
    for (final t in tiers) {
      if (t.name == 'Standard') {
        defaultTierId = t.id;
        break;
      }
    }
    setState(() {
      _tiers = tiers;
      _loadingTiers = false;
      _selectedTierId =
          defaultTierId ?? (tiers.isNotEmpty ? tiers.first.id : null);
    });
    _updateFinalPrice();
  }

  Future<void> _checkPendingDrive() async {
    final user = UserProvider.currentUser;
    if (user == null) return;
    final provider = DriverRequestProvider();
    final result = await provider.get(
      filter: {'userId': user.id, 'status': 'Pending'},
    );
    if (result.items != null && result.items!.isNotEmpty) {
      setState(() {
        _pendingDrive = result.items!.first;
        _waitingForDriver = true;
        _showForm = false;
      });
    } else {
      setState(() {
        _pendingDrive = null;
        _waitingForDriver = false;
        _showForm = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onRequestDrivePressed() {
    setState(() {
      _showForm = true;
    });
  }

  void _onStartSelected(String? loc) {
    setState(() {
      _startLocation = loc;
      _endLocation = null;
      _distanceKm = null;
    });
  }

  void _onEndSelected(String? loc) {
    setState(() {
      _endLocation = loc;
    });
  }

  void _onDistanceChanged(double? km) {
    setState(() {
      _distanceKm = km;
      _basePrice = (km != null) ? (km * 3.0) : null;
      _updateFinalPrice();
    });
  }

  void _onTierSelected(int id) {
    setState(() {
      _selectedTierId = id;
      _updateFinalPrice();
    });
  }

  void _updateFinalPrice() {
    if (_basePrice == null || _selectedTierId == null) {
      _finalPrice = null;
      return;
    }
    final tier = _tiers.firstWhere(
      (t) => t.id == _selectedTierId,
      orElse: () => VehicleTier(),
    );
    double multiplier = 1.0;
    if (tier.name == 'Premium') multiplier = 1.25;
    if (tier.name == 'Luxury') multiplier = 1.5;
    _finalPrice = _basePrice! * multiplier;
  }

  Future<void> _submitRequest() async {
    if (_startLocation == null ||
        _endLocation == null ||
        _selectedTierId == null ||
        _basePrice == null) {
      setState(() {
        _error = 'Please select all required fields.';
      });
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final provider = DriverRequestProvider();
      final user = UserProvider.currentUser;
      final req = {
        'userId': user?.id,
        'vehicleTierId': _selectedTierId,
        'startLocation': _startLocation,
        'endLocation': _endLocation,
        'basePrice': _basePrice,
      };
      await provider.insert(req);
      await _checkPendingDrive(); // refresh state after submit
      setState(() {
        _submitting = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _submitting = false;
      });
    }
  }

  Widget _buildTierCard(VehicleTier tier) {
    final selected = _selectedTierId == tier.id;
    return GestureDetector(
      onTap: () => _onTierSelected(tier.id),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 250),
        margin: EdgeInsets.symmetric(horizontal: 6),
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16), // smaller
        decoration: BoxDecoration(
          color: selected ? Colors.orange.shade100 : Colors.white,
          border: Border.all(
            color: selected ? Colors.deepOrange : Colors.grey.shade300,
            width: selected ? 2.5 : 1.0,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.15),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              tier.name == 'Standard'
                  ? Icons.directions_car
                  : tier.name == 'Premium'
                  ? Icons.star
                  : Icons.diamond,
              color: selected ? Colors.deepOrange : Colors.grey,
              size: 28,
            ),
            SizedBox(height: 6),
            Text(
              tier.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: selected ? Colors.deepOrange : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Removed 'Request a Drive' text
            SizedBox(height: 8),
            CustomMapViewWithSelection(
              height: 320,
              width: MediaQuery.of(context).size.width * 0.95,
              onStartSelected: (loc) {
                _onStartSelected(loc);
                _onDistanceChanged(null);
              },
              onEndSelected: (loc) async {
                _onEndSelected(loc);
              },
              onDistanceChanged: _onDistanceChanged,
            ),
            SizedBox(height: 18),
            if (_loadingTiers)
              CircularProgressIndicator()
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _tiers.map(_buildTierCard).toList(),
                ),
              ),
            SizedBox(height: 18),
            if (_finalPrice != null)
              Text(
                'Final Price: ${_finalPrice!.toStringAsFixed(2)} KM',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87, // modern, neutral color
                ),
              ),
            SizedBox(height: 24),
            if (_error != null)
              Text(_error!, style: TextStyle(color: Colors.red)),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _submitting ? null : _submitRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                minimumSize: Size(double.infinity, 48), // full width, height 48
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.black12, width: 1.2),
                ),
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                elevation: 2,
              ),
              child: _submitting
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.black87,
                        strokeWidth: 2,
                      ),
                    )
                  : Text('Accept'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernRequestCard() {
    return Center(
      child: GestureDetector(
        onTap: _onRequestDrivePressed,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          width: 340,
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              colors: [
                Color(0xFF232526),
                Color(0xFF414345),
                Color(0xFF6a11cb),
                Color(0xFF2575fc),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 24,
                spreadRadius: 2,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Icon(
                  Icons.local_taxi,
                  size: 64,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 12,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 32.0,
                    horizontal: 8,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Need a Ride?',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                          letterSpacing: 1.1,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Tap to request a taxi quickly and safely.',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernWaitingScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 600),
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF6a11cb), Color(0xFF2575fc)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.hourglass_top,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'Looking for a driver...',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF232526),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Hang tight! We’re matching you with the nearest available driver.',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _waitingForDriver = false;
                      _showForm = false;
                      _pendingDrive = null;
                      _startLocation = null;
                      _endLocation = null;
                      _distanceKm = null;
                      _selectedTierId = null;
                      _basePrice = null;
                      _finalPrice = null;
                    });
                  },
                  icon: Icon(Icons.cancel, color: Colors.white),
                  label: Text(
                    'Cancel Request',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    minimumSize: Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_waitingForDriver) {
      return _buildModernWaitingScreen();
    }
    if (_showForm) {
      return _buildForm();
    }
    return _buildModernRequestCard();
  }
}
