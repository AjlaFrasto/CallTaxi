import 'package:calltaxi_desktop_admin/layouts/master_screen.dart';
import 'package:calltaxi_desktop_admin/model/driver_request.dart';
import 'package:calltaxi_desktop_admin/model/search_result.dart';
import 'package:calltaxi_desktop_admin/providers/driver_request_provider.dart';
import 'package:calltaxi_desktop_admin/screens/drives_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calltaxi_desktop_admin/utils/custom_data_table.dart';
import 'package:calltaxi_desktop_admin/utils/custom_pagination.dart';
import 'package:calltaxi_desktop_admin/utils/text_field_decoration.dart';

class DrivesListScreen extends StatefulWidget {
  const DrivesListScreen({super.key});

  @override
  State<DrivesListScreen> createState() => _DrivesListScreenState();
}

class _DrivesListScreenState extends State<DrivesListScreen> {
  late DriverRequestProvider driverRequestProvider;
  TextEditingController searchController = TextEditingController();
  SearchResult<DriverRequest>? drives;
  int _currentPage = 0;
  int _pageSize = 7;
  final List<int> _pageSizeOptions = [5, 7, 10, 20, 50];

  Future<void> _performSearch({int? page, int? pageSize}) async {
    final int pageToFetch = page ?? _currentPage;
    final int pageSizeToUse = pageSize ?? _pageSize;
    var filter = {
      "page": pageToFetch,
      "pageSize": pageSizeToUse,
      "includeTotalCount": true,
      "fts": searchController.text,
    };
    var drives = await driverRequestProvider.get(filter: filter);
    setState(() {
      this.drives = drives;
      _currentPage = pageToFetch;
      _pageSize = pageSizeToUse;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      driverRequestProvider = context.read<DriverRequestProvider>();
      await _performSearch(page: 0);
    });
  }

  Widget _buildResultView() {
    final isEmpty =
        drives == null || drives!.items == null || drives!.items!.isEmpty;
    final int totalCount = drives?.totalCount ?? 0;
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
                "Drive Number",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            DataColumn(
              label: Text(
                "User",
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
                "Vehicle",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            DataColumn(
              label: Text(
                "Vehicle Tier",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
              DataColumn(
                label: Text(
                  "Final Price",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ), 
              DataColumn(
                label: Text(
                  "Status",
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
              : drives!.items!
                    .map(
                      (e) => DataRow(
                        cells: [
                          DataCell(
                            Text(
                              e.id.toString(),
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                          DataCell(
                            Text(
                              e.userFullName ?? '-',
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                          DataCell(
                            Text(
                              e.driverFullName ?? '-',
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                          DataCell(
                            Text(
                              e.vehicleName ?? '-',
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
                            Text(
                              "${e.finalPrice.toStringAsFixed(2)} KM",
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                           DataCell(
                            Text(
                              e.statusName ?? '-',
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                          DataCell(
                            IconButton(
                              icon: Icon(Icons.info_outline),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DrivesDetailsScreen(drive: e),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
          emptyIcon: Icons.drive_eta,
          emptyText: "No drive requests found.",
          emptySubtext: "Try adjusting your search.",
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

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Drives",
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
                        "Search by user, driver, vehicle...",
                        prefixIcon: Icons.search,
                      ),
                      controller: searchController,
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
