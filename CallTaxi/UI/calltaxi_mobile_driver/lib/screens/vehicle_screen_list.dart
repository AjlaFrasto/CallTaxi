import 'package:flutter/material.dart';
import 'package:calltaxi_mobile_driver/model/vehicle.dart';
import 'package:calltaxi_mobile_driver/model/search_result.dart';
import 'package:calltaxi_mobile_driver/providers/vehicle_provider.dart';
import 'package:calltaxi_mobile_driver/providers/user_provider.dart';
import 'package:calltaxi_mobile_driver/utils/text_field_decoration.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:calltaxi_mobile_driver/screens/vehicle_details_screen.dart';

class VehicleScreenList extends StatefulWidget {
  const VehicleScreenList({super.key});

  @override
  State<VehicleScreenList> createState() => _VehicleScreenListState();
}

class _VehicleScreenListState extends State<VehicleScreenList> {
  late VehicleProvider vehicleProvider;
  TextEditingController searchController = TextEditingController();
  SearchResult<Vehicle>? vehicles;
  bool _isLoading = false;
  String _searchText = '';

  Future<void> _performSearch() async {
    if (UserProvider.currentUser == null) {
      print("No current user found");
      return;
    }

    setState(() => _isLoading = true);

    try {
      var filter = {
        "page": 0,
        "pageSize": 50,
        "includeTotalCount": true,
        "fts": _searchText,
        "userId": UserProvider.currentUser!.id, // Filter by current user
      };

      var result = await vehicleProvider.get(filter: filter);
      setState(() {
        vehicles = result;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching vehicles: $e");
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error loading vehicles: $e")));
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      vehicleProvider = Provider.of<VehicleProvider>(context, listen: false);
      await _performSearch();
    });
  }

  Widget _buildVehicleCard(Vehicle vehicle) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VehicleDetailsScreen(
                vehicle: vehicle,
                onVehicleSaved: () {
                  // Refresh the vehicle list when a vehicle is saved
                  _performSearch();
                },
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Vehicle Image with brand logo overlay
                  Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[200],
                        ),
                        child:
                            vehicle.picture != null &&
                                vehicle.picture!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  base64Decode(vehicle.picture!),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(
                                        Icons.directions_car,
                                        size: 40,
                                        color: Colors.grey[600],
                                      ),
                                ),
                              )
                            : Icon(
                                Icons.directions_car,
                                size: 40,
                                color: Colors.grey[600],
                              ),
                      ),
                      // Brand logo in top right corner of vehicle image
                      if (vehicle.brandLogo != null &&
                          vehicle.brandLogo!.isNotEmpty)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 2,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.memory(
                                base64Decode(vehicle.brandLogo!),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(
                                      Icons.branding_watermark,
                                      size: 12,
                                      color: Colors.grey[600],
                                    ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Combined brand name + vehicle name
                        Text(
                          "${vehicle.brandName} ${vehicle.name}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          vehicle.licensePlate,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status indicator in top right corner
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(vehicle.stateMachine),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      vehicle.stateMachine,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              // Vehicle details
              Row(
                children: [
                  _buildDetailChip(Icons.palette, vehicle.color),
                  SizedBox(width: 8),
                  _buildDetailChip(
                    Icons.calendar_today,
                    vehicle.yearOfManufacture.toString(),
                  ),
                  SizedBox(width: 8),
                  _buildDetailChip(
                    Icons.airline_seat_recline_normal,
                    "${vehicle.seatsCount} seats",
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  if (vehicle.petFriendly)
                    _buildDetailChip(
                      Icons.pets,
                      "Pet Friendly",
                      color: Colors.green,
                      textColor: Colors.white,
                    ),
                  SizedBox(width: 8),
                  if (vehicle.vehicleTierName != null)
                    _buildDetailChip(Icons.star, vehicle.vehicleTierName!),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailChip(
    IconData icon,
    String label, {
    Color? color,
    Color? textColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color ?? Colors.orange[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor ?? color ?? Colors.orange[800]),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: textColor ?? color ?? Colors.orange[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: customTextFieldDecoration(
                      "Search",
                      prefixIcon: Icons.search,
                    ),
                    onChanged: (value) {
                      setState(() => _searchText = value);
                    },
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _performSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF6F00),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text("Search", style: TextStyle(color: Colors.white)),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VehicleDetailsScreen(
                          onVehicleSaved: () {
                            // Refresh the vehicle list when a vehicle is saved
                            _performSearch();
                          },
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text("Add Car", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
          // Vehicle list
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : vehicles == null || vehicles!.items?.isEmpty == true
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.directions_car_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          "No vehicles found",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Add a vehicle to get started",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _performSearch,
                    child: ListView.builder(
                      padding: EdgeInsets.only(bottom: 16),
                      itemCount: vehicles!.items?.length ?? 0,
                      itemBuilder: (context, index) {
                        return _buildVehicleCard(vehicles!.items![index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
