import 'dart:typed_data';
import 'dart:convert';
import 'package:calltaxi_desktop_admin/layouts/master_screen.dart';
import 'package:calltaxi_desktop_admin/model/brand.dart';
import 'package:calltaxi_desktop_admin/model/search_result.dart';
import 'package:calltaxi_desktop_admin/providers/brand_provider.dart';
import 'package:calltaxi_desktop_admin/screens/brand_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calltaxi_desktop_admin/utils/text_field_decoration.dart';
import 'package:calltaxi_desktop_admin/utils/custom_data_table.dart';
import 'package:calltaxi_desktop_admin/utils/custom_pagination.dart';

class BrandListScreen extends StatefulWidget {
  const BrandListScreen({super.key});

  @override
  State<BrandListScreen> createState() => _BrandListScreenState();
}

class _BrandListScreenState extends State<BrandListScreen> {
  late BrandProvider brandProvider;
  TextEditingController nameController = TextEditingController();
  SearchResult<Brand>? brands;
  int _currentPage = 0;
  int _pageSize = 7;
  final List<int> _pageSizeOptions = [5, 7, 10, 20, 50];

  Future<void> _performSearch({int? page, int? pageSize}) async {
    final int pageToFetch = page ?? _currentPage;
    final int pageSizeToUse = pageSize ?? _pageSize;
    var filter = {
      "name": nameController.text,
      "page": pageToFetch,
      "pageSize": pageSizeToUse,
      "includeTotalCount": true,
    };
    var brands = await brandProvider.get(filter: filter);
    setState(() {
      this.brands = brands;
      _currentPage = pageToFetch;
      _pageSize = pageSizeToUse;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      brandProvider = context.read<BrandProvider>();
      await _performSearch(page: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Brands",
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
                MaterialPageRoute(builder: (context) => BrandDetailsScreen()),
              );
            },
            style: ElevatedButton.styleFrom(foregroundColor: Colors.lightBlue),
            child: Text("Add Brand"),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    final isEmpty =
        brands == null || brands!.items == null || brands!.items!.isEmpty;
    final int totalCount = brands?.totalCount ?? 0;
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
                "Logo",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            DataColumn(
              label: Text(
                "Name",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
          rows: isEmpty
              ? []
              : brands!.items!
                    .map(
                      (e) => DataRow(
                        onSelectChanged: (value) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  BrandDetailsScreen(brand: e),
                            ),
                          );
                        },
                        cells: [
                          DataCell(_buildLogoCell(e.logo)),
                          DataCell(
                            Text(e.name, style: TextStyle(fontSize: 15)),
                          ),
                        ],
                      ),
                    )
                    .toList(),
          emptyIcon: Icons.branding_watermark,
          emptyText: "No brands found.",
          emptySubtext: "Try adjusting your search or add a new brand.",
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

  Widget _buildLogoCell(String? logoBase64) {
    if (logoBase64 == null || logoBase64.isEmpty) {
      return Icon(Icons.image_not_supported, size: 32, color: Colors.grey);
    }
    try {
      final bytes = base64Decode(logoBase64);
      return Image.memory(
        bytes,
        width: 32,
        height: 32,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.broken_image, size: 32, color: Colors.grey),
      );
    } catch (e) {
      return Icon(Icons.broken_image, size: 32, color: Colors.grey);
    }
  }
}
