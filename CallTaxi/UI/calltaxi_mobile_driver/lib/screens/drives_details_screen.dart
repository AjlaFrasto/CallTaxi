import 'package:flutter/material.dart';
import 'package:calltaxi_mobile_driver/model/driver_request.dart';
import 'package:calltaxi_mobile_driver/model/vehicle.dart';
import 'package:calltaxi_mobile_driver/model/search_result.dart';
import 'package:calltaxi_mobile_driver/providers/driver_request_provider.dart';
import 'package:calltaxi_mobile_driver/providers/vehicle_provider.dart';
import 'package:calltaxi_mobile_driver/providers/user_provider.dart';
import 'package:calltaxi_mobile_driver/utils/text_field_decoration.dart';
import 'package:calltaxi_mobile_driver/utils/custom_map_view.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class DrivesDetailsScreen extends StatefulWidget {
  final DriverRequest drive;
  final bool isPending;
  final Function(int)? onTabChanged;

  const DrivesDetailsScreen({
    super.key,
    required this.drive,
    required this.isPending,
    this.onTabChanged,
  });

  @override
  State<DrivesDetailsScreen> createState() => _DrivesDetailsScreenState();
}

class _DrivesDetailsScreenState extends State<DrivesDetailsScreen> {
  late DriverRequestProvider driverRequestProvider;
  late VehicleProvider vehicleProvider;
  List<Vehicle> _driverVehicles = [];
  bool _isLoadingVehicles = false;
  bool _isAccepting = false;
  Vehicle? _selectedVehicle;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      driverRequestProvider = Provider.of<DriverRequestProvider>(
        context,
        listen: false,
      );
      vehicleProvider = Provider.of<VehicleProvider>(context, listen: false);

      if (widget.isPending) {
        await _loadDriverVehicles();
      }
    });
  }

  Future<void> _loadDriverVehicles() async {
    if (UserProvider.currentUser == null) return;

    setState(() {
      _isLoadingVehicles = true;
    });

    try {
      final result = await vehicleProvider.get(
        filter: {
          "userId": UserProvider.currentUser!.id,
          "vehicleTierId":
              widget.drive.vehicleTierId, // Filter by same tier as drive
        },
      );

      setState(() {
        _driverVehicles = result.items ?? [];
        _isLoadingVehicles = false;
      });

      // Auto-select first vehicle if available
      if (_driverVehicles.isNotEmpty) {
        _selectedVehicle = _driverVehicles.first;
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load vehicles: $e";
        _isLoadingVehicles = false;
      });
    }
  }

  Future<void> _acceptDrive() async {
    if (_selectedVehicle == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please select a vehicle")));
      return;
    }

    if (UserProvider.currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("User not found")));
      return;
    }

    setState(() {
      _isAccepting = true;
    });

    try {
      await driverRequestProvider.accept(
        widget.drive.id,
        UserProvider.currentUser!.id,
        _selectedVehicle!.id,
      );

      setState(() {
        _isAccepting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Drive accepted successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      // Add a small delay to ensure the backend has processed the acceptance
      await Future.delayed(Duration(milliseconds: 500));

      // Navigate back to the calltaxi_screen (index 0) when drive is accepted
      if (widget.onTabChanged != null) {
        // Switch to CallTaxiScreen tab directly
        widget.onTabChanged!(0); // Switch back to CallTaxiScreen tab
        // Then pop the current screen to go back to the drives list
        Navigator.of(context).pop();
      } else {
        Navigator.of(
          context,
        ).pop(true); // Fallback: return true to indicate success
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to accept drive: $e";
        _isAccepting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to accept drive: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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

  Widget _buildVehicleDropdown() {
    if (_isLoadingVehicles) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text("Loading vehicles..."),
            ],
          ),
        ),
      );
    }

    if (_driverVehicles.isEmpty) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange, size: 24),
                  SizedBox(width: 12),
                  Text(
                    "No Compatible Vehicles",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                "You don't have any vehicles that match the ${widget.drive.vehicleTierName ?? 'requested'} tier.",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.directions_car, color: Colors.blue, size: 24),
                SizedBox(width: 12),
                Text(
                  "Select Vehicle",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<Vehicle>(
              value: _selectedVehicle,
              decoration: customTextFieldDecoration(
                "Choose your vehicle",
                prefixIcon: Icons.directions_car,
              ),
              items: _driverVehicles.map((vehicle) {
                return DropdownMenuItem<Vehicle>(
                  value: vehicle,
                  child: Text("${vehicle.name} (${vehicle.licensePlate})"),
                );
              }).toList(),
              onChanged: (Vehicle? value) {
                setState(() {
                  _selectedVehicle = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return "Please select a vehicle";
                }
                return null;
              },
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
        title: Text(
          widget.isPending ? 'Pending Drive Details' : 'Drive Details',
        ),
        backgroundColor: widget.isPending ? Colors.orange : Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Error message display
                  if (_errorMessage != null)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red[800]),
                      ),
                    ),

                  // Header with status
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: widget.isPending
                          ? Colors.orange.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: widget.isPending
                            ? Colors.orange.withOpacity(0.3)
                            : Colors.green.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          widget.isPending
                              ? Icons.schedule
                              : Icons.check_circle,
                          color: widget.isPending
                              ? Colors.orange
                              : Colors.green,
                          size: 32,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.isPending ? 'Pending' : 'Completed',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: widget.isPending
                                      ? Colors.orange
                                      : Colors.green,
                                ),
                              ),
                              Text(
                                widget.isPending
                                    ? 'Client is waiting for a driver'
                                    : 'This drive has been completed successfully',
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

                  // Client information (for pending drives)
                  if (widget.isPending &&
                      widget.drive.userFullName != null) ...[
                    Text(
                      'Client Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildInfoCard(
                      'Client Name',
                      widget.drive.userFullName!,
                      Icons.person,
                      Colors.indigo,
                    ),
                    SizedBox(height: 24),
                  ],

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
                    start: widget.drive.startLocation,
                    end: widget.drive.endLocation,
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
                    '${widget.drive.finalPrice.toStringAsFixed(2)} KM',
                    Icons.attach_money,
                    Colors.green,
                  ),
                  _buildInfoCard(
                    'Base Price',
                    '${widget.drive.basePrice.toStringAsFixed(2)} KM',
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
                    '${widget.drive.distance.toStringAsFixed(1)} km',
                    Icons.straighten,
                    Colors.orange,
                  ),
                  _buildInfoCard(
                    'Vehicle Tier',
                    widget.drive.vehicleTierName ?? 'Unknown',
                    Icons.local_taxi,
                    Colors.purple,
                  ),
                  SizedBox(height: 24),

                  // Vehicle selection (for pending drives)
                  if (widget.isPending) ...[
                    _buildVehicleDropdown(),
                    SizedBox(height: 24),
                  ],

                  // Driver information (for completed drives)
                  if (!widget.isPending &&
                      widget.drive.driverFullName != null) ...[
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
                      widget.drive.driverFullName!,
                      Icons.person,
                      Colors.indigo,
                    ),
                    if (widget.drive.vehicleName != null)
                      _buildInfoCard(
                        'Vehicle',
                        widget.drive.vehicleName!,
                        Icons.directions_car,
                        Colors.teal,
                      ),
                    if (widget.drive.vehicleLicensePlate != null)
                      _buildInfoCard(
                        'License Plate',
                        widget.drive.vehicleLicensePlate!,
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
                    _formatDateTime(widget.drive.createdAt),
                    Icons.schedule,
                    Colors.grey,
                  ),
                  if (widget.drive.acceptedAt != null)
                    _buildInfoCard(
                      'Accepted',
                      _formatDateTime(widget.drive.acceptedAt!),
                      Icons.thumb_up,
                      Colors.blue,
                    ),
                  if (widget.drive.completedAt != null)
                    _buildInfoCard(
                      'Completed',
                      _formatDateTime(widget.drive.completedAt!),
                      Icons.check_circle,
                      Colors.green,
                    ),
                  SizedBox(height: 24),

                  // Trip ID
                  _buildInfoCard(
                    'Trip ID',
                    '#${widget.drive.id.toString().padLeft(6, '0')}',
                    Icons.confirmation_number,
                    Colors.grey,
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // Bottom accept button for pending drives
          if (widget.isPending)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_selectedVehicle == null)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: Text(
                          "Please select a vehicle to accept this drive",
                          style: TextStyle(
                            color: Colors.orange[800],
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isAccepting ? null : _acceptDrive,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isAccepting
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text("Accepting..."),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      "Accept Drive",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
