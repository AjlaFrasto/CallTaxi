import 'package:calltaxi_desktop_admin/layouts/master_screen.dart';
import 'package:calltaxi_desktop_admin/model/city.dart';
import 'package:calltaxi_desktop_admin/model/search_result.dart';
import 'package:calltaxi_desktop_admin/providers/city_provider.dart';
import 'package:calltaxi_desktop_admin/screens/city_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calltaxi_desktop_admin/utils/text_field_decoration.dart';
import 'package:calltaxi_desktop_admin/utils/custom_data_table.dart';
import 'package:calltaxi_desktop_admin/utils/custom_pagination.dart';

class CityListScreen extends StatefulWidget {
  const CityListScreen({super.key});

  @override
  State<CityListScreen> createState() => _CityListScreenState();
}

class _CityListScreenState extends State<CityListScreen> {
  late CityProvider cityProvider;

  TextEditingController nameController = TextEditingController();

  SearchResult<City>? cities;
  int _currentPage = 0;
  int _pageSize = 7;
  final List<int> _pageSizeOptions = [5, 7, 10, 20, 50];

  // Search for cities with ENTER key, not only when button is clicked
  Future<void> _performSearch({int? page, int? pageSize}) async {
    final int pageToFetch = page ?? _currentPage;
    final int pageSizeToUse = pageSize ?? _pageSize;
    var filter = {
      "name": nameController.text,
      "page": pageToFetch,
      "pageSize": pageSizeToUse,
      "includeTotalCount": true, // Ensure backend returns total count
    };
    debugPrint(filter.toString());
    var cities = await cityProvider.get(filter: filter);
    debugPrint(cities.items?.firstOrNull?.name);
    setState(() {
      this.cities = cities;
      _currentPage = pageToFetch;
      _pageSize = pageSizeToUse;
    });
  }

  @override
  void initState() {
    super.initState();
    // Delay to ensure context is available for Provider
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      cityProvider = context.read<CityProvider>();
      await _performSearch(page: 0);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Cities",
      child: Center(
        child: Column(children: [_buildSearch(), _buildResultView()]),
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: customTextFieldDecoration(
                "Name",
                prefixIcon: Icons.search,
              ),
              controller: nameController,
              onSubmitted: (value) => _performSearch(),
            ),
          ),
          SizedBox(width: 10),
          ElevatedButton(onPressed: _performSearch, child: Text("Search")),
          SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CityDetailsScreen()),
              );
            },
            style: ElevatedButton.styleFrom(foregroundColor: Colors.lightBlue),
            child: Text("Add City"),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    final isEmpty =
        cities == null || cities!.items == null || cities!.items!.isEmpty;
    final int totalCount = cities?.totalCount ?? 0;
    final int totalPages = (totalCount / _pageSize).ceil();
    final bool isFirstPage = _currentPage == 0;
    final bool isLastPage = _currentPage >= totalPages - 1 || totalPages == 0;
    return Column(
      children: [
        CustomDataTableCard(
          width: 600,
          height: 450,
          columns: [
            DataColumn(
              label: Text(
                "Name",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
          rows: isEmpty
              ? []
              : cities!.items!
                    .map(
                      (e) => DataRow(
                        onSelectChanged: (value) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CityDetailsScreen(city: e),
                            ),
                          );
                        },
                        cells: [
                          DataCell(
                            Text(e.name, style: TextStyle(fontSize: 15)),
                          ),
                        ],
                      ),
                    )
                    .toList(),
          emptyIcon: Icons.location_city,
          emptyText: "No cities found.",
          emptySubtext: "Try adjusting your search or add a new city.",
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
}
