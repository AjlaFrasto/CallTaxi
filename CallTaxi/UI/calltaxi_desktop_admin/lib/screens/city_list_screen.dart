import 'package:calltaxi_desktop_admin/layouts/master_screen.dart';
import 'package:calltaxi_desktop_admin/model/city.dart';
import 'package:calltaxi_desktop_admin/model/search_result.dart';
import 'package:calltaxi_desktop_admin/providers/city_provider.dart';
import 'package:calltaxi_desktop_admin/screens/city_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calltaxi_desktop_admin/utils/text_field_decoration.dart';
import 'package:calltaxi_desktop_admin/utils/custom_data_table.dart';

class CityListScreen extends StatefulWidget {
  const CityListScreen({super.key});

  @override
  State<CityListScreen> createState() => _CityListScreenState();
}

class _CityListScreenState extends State<CityListScreen> {
  late CityProvider cityProvider;

  TextEditingController nameController = TextEditingController();

  SearchResult<City>? cities;

  // Search for cities with ENTER key, not only when button is clicked
  Future<void> _performSearch() async {
    var filter = {"name": nameController.text};
    debugPrint(filter.toString());
    var cities = await cityProvider.get(filter: filter);
    debugPrint(cities.items?.firstOrNull?.name);
    this.cities = cities;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    // Delay to ensure context is available for Provider
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      cityProvider = context.read<CityProvider>();
      var allCities = await cityProvider.get();
      setState(() {
        cities = allCities;
      });
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
    return CustomDataTableCard(
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
                      DataCell(Text(e.name, style: TextStyle(fontSize: 15))),
                    ],
                  ),
                )
                .toList(),
      emptyIcon: Icons.location_city,
      emptyText: "No cities found.",
      emptySubtext: "Try adjusting your search or add a new city.",
    );
  }
}
