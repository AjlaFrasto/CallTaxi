import 'dart:convert';
import 'package:calltaxi_desktop_admin/layouts/master_screen.dart';
import 'package:calltaxi_desktop_admin/model/vehicle.dart';
import 'package:calltaxi_desktop_admin/model/search_result.dart';
import 'package:calltaxi_desktop_admin/providers/vehicle_provider.dart';
import 'package:calltaxi_desktop_admin/screens/vehicle_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calltaxi_desktop_admin/utils/text_field_decoration.dart';
import 'package:calltaxi_desktop_admin/utils/custom_data_table.dart';
import 'package:calltaxi_desktop_admin/utils/custom_pagination.dart';

class VehicleScreenList extends StatefulWidget {
  const VehicleScreenList({super.key});

  @override
  State<VehicleScreenList> createState() => _VehicleScreenListState();
}

class _VehicleScreenListState extends State<VehicleScreenList> {
  late VehicleProvider vehicleProvider;
  TextEditingController nameController = TextEditingController();
  SearchResult<Vehicle>? vehicles;
  int _currentPage = 0;
  int _pageSize = 7;
  final List<int> _pageSizeOptions = [5, 7, 10, 20, 50];

  Future<void> _performSearch({int? page, int? pageSize}) async {
    final int pageToFetch = page ?? _currentPage;
    final int pageSizeToUse = pageSize ?? _pageSize;
    final searchText = nameController.text;
    var filter = {
      "page": pageToFetch,
      "pageSize": pageSizeToUse,
      "includeTotalCount": true,
      "fts": searchText,
    };
    var vehicles = await vehicleProvider.get(filter: filter);
    setState(() {
      this.vehicles = vehicles;
      _currentPage = pageToFetch;
      _pageSize = pageSizeToUse;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      vehicleProvider = context.read<VehicleProvider>();
      await _performSearch(page: 0);
    });
  }

  Widget _buildImageCell(
    String? base64, {
    double size = 32,
    IconData? fallbackIcon,
  }) {
    if (base64 == null || base64.isEmpty) {
      return Icon(fallbackIcon ?? Icons.image, size: size, color: Colors.grey);
    }
    try {
      final bytes = base64Decode(base64);
      return Image.memory(
        bytes,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Icon(
          fallbackIcon ?? Icons.broken_image,
          size: size,
          color: Colors.grey,
        ),
      );
    } catch (e) {
      return Icon(
        fallbackIcon ?? Icons.broken_image,
        size: size,
        color: Colors.grey,
      );
    }
  }

  Widget _buildResultView() {
    final isEmpty =
        vehicles == null || vehicles!.items == null || vehicles!.items!.isEmpty;
    final int totalCount = vehicles?.totalCount ?? 0;
    final int totalPages = (totalCount / _pageSize).ceil();
    final bool isFirstPage = _currentPage == 0;
    final bool isLastPage = _currentPage >= totalPages - 1 || totalPages == 0;
    return Column(
      children: [
        CustomDataTableCard(
          width: 1300,
          height: 450,
          columns: [
            DataColumn(
              label: Text(
                "Logo",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            DataColumn(
              label: Text(
                "Image",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            DataColumn(
              label: Text(
                "Brand",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            DataColumn(
              label: Text(
                "Model",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            DataColumn(
              label: Text(
                "Driver",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            DataColumn(
              label: Text(
                "Tier",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            DataColumn(
              label: Text(
                "Pet Friendly",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            DataColumn(
              label: Text(
                "State",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            DataColumn(
              label: Text(
                "Actions",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            DataColumn(
              label: Text(
                "Details",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
          rows: isEmpty
              ? []
              : vehicles!.items!
                    .map(
                      (e) => DataRow(
                        cells: [
                          DataCell(
                            _buildImageCell(
                              e.brandLogo,
                              fallbackIcon: Icons.branding_watermark,
                            ),
                          ),
                          DataCell(
                            _buildImageCell(
                              e.picture,
                              fallbackIcon: Icons.directions_car,
                            ),
                          ),
                          DataCell(
                            Text(e.brandName, style: TextStyle(fontSize: 15)),
                          ),
                          DataCell(
                            Text(e.name, style: TextStyle(fontSize: 15)),
                          ),
                          DataCell(
                            Text(
                              e.userFullName ?? '-',
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                          DataCell(
                            Text(
                              e.vehicleTierName ?? '-',
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                          DataCell(
                            Icon(
                              e.petFriendly ? Icons.pets : Icons.block,
                              color: e.petFriendly ? Colors.green : Colors.red,
                            ),
                          ),
                          DataCell(
                            Text(
                              e.stateMachine,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataCell(_buildActionsCell(e)),
                          DataCell(
                            IconButton(
                              icon: Icon(Icons.info_outline),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        VehicleDetailsScreen(vehicle: e),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
          emptyIcon: Icons.directions_car,
          emptyText: "No vehicles found.",
          emptySubtext: "Try adjusting your search or add a new vehicle.",
        ),
        SizedBox(height: 10),
        CustomPagination(
          currentPage: _currentPage,
          totalPages: totalPages,
          onPrevious: isFirstPage
              ? null
              : () => _performSearch(page: _currentPage - 1),
          onNext: isLastPage
              ? null
              : () => _performSearch(page: _currentPage + 1),
          showPageSizeSelector: true,
          pageSize: _pageSize,
          pageSizeOptions: _pageSizeOptions,
          onPageSizeChanged: (newSize) {
            if (newSize != null && newSize != _pageSize) {
              _performSearch(page: 0, pageSize: newSize);
            }
          },
        ),
      ],
    );
  }

  Widget _buildActionsCell(Vehicle vehicle) {
    if (vehicle.stateMachine == 'Pending') {
      return Row(
        children: [
          IconButton(
            icon: Icon(Icons.check, color: Colors.green),
            tooltip: 'Accept',
            onPressed: () async {
              await vehicleProvider.accept(vehicle.id);
              await _performSearch();
            },
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.red),
            tooltip: 'Reject',
            onPressed: () async {
              await vehicleProvider.reject(vehicle.id);
              await _performSearch();
            },
          ),
        ],
      );
    } else {
      return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Vehicles",
      child: Center(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: customTextFieldDecoration(
                        "Model, Brand, Driver Name...",
                        prefixIcon: Icons.search,
                      ),
                      controller: nameController,
                      onSubmitted: (value) => _performSearch(),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _performSearch,
                    child: Text("Search"),
                  ),
                ],
              ),
            ),
            _buildResultView(),
          ],
        ),
      ),
    );
  }
}
