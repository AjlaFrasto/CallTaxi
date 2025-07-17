import 'dart:convert';
import 'package:calltaxi_desktop_admin/layouts/master_screen.dart';
import 'package:calltaxi_desktop_admin/model/user.dart';
import 'package:calltaxi_desktop_admin/model/search_result.dart';
import 'package:calltaxi_desktop_admin/providers/user_provider.dart';
import 'package:calltaxi_desktop_admin/screens/user_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calltaxi_desktop_admin/utils/text_field_decoration.dart';
import 'package:calltaxi_desktop_admin/utils/custom_data_table.dart';
import 'package:calltaxi_desktop_admin/utils/custom_pagination.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late UserProvider userProvider;
  TextEditingController nameController = TextEditingController();
  SearchResult<User>? users;
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
      "fts": nameController.text,
    };
    var users = await userProvider.get(filter: filter);
    setState(() {
      this.users = users;
      _currentPage = pageToFetch;
      _pageSize = pageSizeToUse;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      userProvider = context.read<UserProvider>();
      await _performSearch(page: 0);
    });
  }

  Widget _buildPictureCell(String? pictureBase64) {
    if (pictureBase64 == null || pictureBase64.isEmpty) {
      return Icon(Icons.account_circle, size: 32, color: Colors.grey);
    }
    try {
      final bytes = base64Decode(pictureBase64);
      return CircleAvatar(backgroundImage: MemoryImage(bytes), radius: 16);
    } catch (e) {
      return Icon(Icons.account_circle, size: 32, color: Colors.grey);
    }
  }

  Widget _buildResultView() {
    final isEmpty =
        users == null || users!.items == null || users!.items!.isEmpty;
    final int totalCount = users?.totalCount ?? 0;
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
                "Picture",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            DataColumn(
              label: Text(
                "Name",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            DataColumn(
              label: Text(
                "Email",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            DataColumn(
              label: Text(
                "Username",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            DataColumn(
              label: Text(
                "Roles",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            DataColumn(
              label: Text(
                "City",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            DataColumn(
              label: Text(
                "Created At",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            DataColumn(
              label: Text(
                "Active",
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
              : users!.items!
                    .map(
                      (e) => DataRow(
                        cells: [
                          DataCell(_buildPictureCell(e.picture)),
                          DataCell(
                            Text(
                              "${e.firstName} ${e.lastName}",
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                          DataCell(
                            Text(e.email, style: TextStyle(fontSize: 15)),
                          ),
                          DataCell(
                            Text(e.username, style: TextStyle(fontSize: 15)),
                          ),
                          DataCell(Text(e.roles.map((r) => r.name).join(", "))),
                          DataCell(
                            Text(e.cityName, style: TextStyle(fontSize: 15)),
                          ),
                          DataCell(
                            Text(
                              e.createdAt.toString().split(" ")[0],
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                          DataCell(
                            Icon(
                              e.isActive ? Icons.check : Icons.close,
                              color: e.isActive ? Colors.green : Colors.red,
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
                                        UserDetailsScreen(user: e),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
          emptyIcon: Icons.people,
          emptyText: "No users found.",
          emptySubtext: "Try adjusting your search or add a new user.",
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
      title: "Users",
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
                        "Name, Email, Username...",
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
