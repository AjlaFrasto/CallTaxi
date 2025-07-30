import 'package:flutter/material.dart';
import 'package:calltaxi_mobile_client/model/driver_request.dart';
import 'package:calltaxi_mobile_client/model/search_result.dart';
import 'package:calltaxi_mobile_client/providers/driver_request_provider.dart';
import 'package:calltaxi_mobile_client/providers/user_provider.dart';
import 'package:calltaxi_mobile_client/providers/review_provider.dart';
import 'package:calltaxi_mobile_client/utils/text_field_decoration.dart';
import 'package:provider/provider.dart';
import 'package:calltaxi_mobile_client/screens/review_details_screen.dart';
import 'dart:convert';

class DriveSelectionScreen extends StatefulWidget {
  const DriveSelectionScreen({super.key});

  @override
  State<DriveSelectionScreen> createState() => _DriveSelectionScreenState();
}

class _DriveSelectionScreenState extends State<DriveSelectionScreen> {
  late DriverRequestProvider driverRequestProvider;
  late ReviewProvider reviewProvider;
  TextEditingController searchController = TextEditingController();
  SearchResult<DriverRequest>? drives;
  bool _isLoading = false;
  String _searchText = '';

  Future<void> _performSearch() async {
    if (UserProvider.currentUser == null) {
      print("No current user found");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get completed drives for current user
      var filter = {
        "page": 0,
        "pageSize": 100,
        "includeTotalCount": true,
        "fts": _searchText,
        "userId": UserProvider.currentUser!.id,
        "status": "Completed", // Only completed drives
      };

      var result = await driverRequestProvider.get(filter: filter);

      // Filter out drives that already have reviews
      var unreviewedDrives = <DriverRequest>[];
      for (var drive in result.items ?? []) {
        // Check if this drive already has a review
        var reviewFilter = {
          "page": 0,
          "pageSize": 1,
          "includeTotalCount": true,
          "driveRequestId": drive.id,
          "userId": UserProvider.currentUser!.id,
        };

        var reviewResult = await reviewProvider.get(filter: reviewFilter);
        if (reviewResult.items == null || reviewResult.items!.isEmpty) {
          unreviewedDrives.add(drive);
        }
      }

      setState(() {
        drives = SearchResult<DriverRequest>()
          ..items = unreviewedDrives
          ..totalCount = unreviewedDrives.length;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching drives: $e");
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error loading drives: $e")));
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      driverRequestProvider = Provider.of<DriverRequestProvider>(
        context,
        listen: false,
      );
      reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
      await _performSearch();
    });
  }

  Widget _buildDriveCard(DriverRequest drive) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ReviewDetailsScreen(driveRequest: drive, isNewReview: true),
            ),
          ).then((_) {
            // Refresh drive list when returning from review details
            _performSearch();
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.local_taxi, color: Colors.orange, size: 40),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Drive #${drive.id.toString().padLeft(6, '0')}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        if (drive.driverFullName != null)
                          Text(
                            'Driver: ${drive.driverFullName}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        SizedBox(height: 4),
                        Text(
                          '${drive.vehicleTierName ?? 'Unknown'} Tier',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${drive.finalPrice.toStringAsFixed(2)} KM',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${drive.distance.toStringAsFixed(1)} km',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Tap to Review',
                    style: TextStyle(
                      color: Colors.orange.shade800,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Drive to Review"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: customTextFieldDecoration(
                "Search drives",
                prefixIcon: Icons.search,
              ),
              onChanged: (value) {
                setState(() => _searchText = value);
                _performSearch();
              },
            ),
          ),
          // Drives list
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : drives == null || drives!.items?.isEmpty == true
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_taxi_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          "No drives to review",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "All your completed rides have been reviewed",
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
                      itemCount: drives!.items?.length ?? 0,
                      itemBuilder: (context, index) {
                        return _buildDriveCard(drives!.items![index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
