import 'package:flutter/material.dart';
import 'package:calltaxi_mobile_client/model/driver_request.dart';
import 'package:calltaxi_mobile_client/model/search_result.dart';
import 'package:calltaxi_mobile_client/providers/driver_request_provider.dart';
import 'package:calltaxi_mobile_client/providers/user_provider.dart';
import 'package:calltaxi_mobile_client/utils/text_field_decoration.dart';
import 'package:provider/provider.dart';
import 'package:calltaxi_mobile_client/screens/drives_details_screen.dart';

class DrivesListScreen extends StatefulWidget {
  const DrivesListScreen({super.key});

  @override
  State<DrivesListScreen> createState() => _DrivesListScreenState();
}

class _DrivesListScreenState extends State<DrivesListScreen> {
  late DriverRequestProvider driverRequestProvider;
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
      var filter = {
        "page": 0,
        "pageSize": 100,
        "includeTotalCount": true,
        "fts": _searchText,
        "userId": UserProvider.currentUser!.id,
        "status": "Completed", // Filter for completed drives only
      };

      var result = await driverRequestProvider.get(filter: filter);

      setState(() {
        drives = result;
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
      await _performSearch();
    });
  }

  Widget _buildDriveCard(DriverRequest drive) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DrivesDetailsScreen(drive: drive),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '#${drive.id.toString().padLeft(4, '0')}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 8),
                      Icon(Icons.local_taxi, color: Colors.orange, size: 40),
                    ],
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (drive.driverFullName != null)
                          Text(
                            'Driver: ${drive.driverFullName ?? 'Unknown'}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        SizedBox(height: 4),
                        Text(
                          '${drive.vehicleTierName ?? 'Unknown'} Tier Drive',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        '${drive.finalPrice.toStringAsFixed(2)} KM',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _formatTime(drive.createdAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Completed',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
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
                          "No completed drives found",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Your completed rides will appear here",
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
