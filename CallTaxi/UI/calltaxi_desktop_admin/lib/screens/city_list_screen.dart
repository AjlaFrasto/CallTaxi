import 'package:calltaxi_desktop_admin/layouts/master_screen.dart';
import 'package:calltaxi_desktop_admin/model/city.dart';
import 'package:calltaxi_desktop_admin/model/search_result.dart';
import 'package:calltaxi_desktop_admin/providers/city_provider.dart';
import 'package:calltaxi_desktop_admin/screens/city_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calltaxi_desktop_admin/utils/text_field_decoration.dart';

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
    return Center(
      child: Card(
        elevation: 4,
        margin: EdgeInsets.all(16),
        child: Container(
          width: 600,
          height: 450,
          padding: EdgeInsets.all(16),
          child: cities == null
              ? Center(child: CircularProgressIndicator())
              : (cities!.items == null || cities!.items!.isEmpty)
              ? Container(
                  width: 400,
                  height: 200,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_city,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        "No cities found.",
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Try adjusting your search or add a new city.",
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : SizedBox(
                  height: 350,
                  child: SingleChildScrollView(
                    child: DataTable(
                      showCheckboxColumn: false,
                      columnSpacing: 24,
                      headingRowColor:
                          WidgetStateProperty.resolveWith<Color?>(
                            (states) => Colors.blue[50],
                          ),
                      dataRowColor: WidgetStateProperty.resolveWith<Color?>((
                        states,
                      ) {
                        if (states.contains(WidgetState.hovered)) {
                          return Colors.blue.withAlpha(20);
                        }
                        return null;
                      }),
                      columns: [
                        DataColumn(
                          label: Text(
                            "Name",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                      rows: cities!.items!
                          .map(
                            (e) => DataRow(
                              onSelectChanged: (value) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CityDetailsScreen(city: e),
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
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
