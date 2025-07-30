import 'package:flutter/material.dart';
import 'package:calltaxi_mobile_client/model/review.dart';
import 'package:calltaxi_mobile_client/model/search_result.dart';
import 'package:calltaxi_mobile_client/providers/review_provider.dart';
import 'package:calltaxi_mobile_client/providers/user_provider.dart';
import 'package:calltaxi_mobile_client/utils/text_field_decoration.dart';
import 'package:provider/provider.dart';
import 'package:calltaxi_mobile_client/screens/review_details_screen.dart';
import 'package:calltaxi_mobile_client/screens/drive_selection_screen.dart';
import 'dart:convert'; // Added for base64Decode

class ReviewListScreen extends StatefulWidget {
  const ReviewListScreen({super.key});

  @override
  State<ReviewListScreen> createState() => _ReviewListScreenState();
}

class _ReviewListScreenState extends State<ReviewListScreen> {
  late ReviewProvider reviewProvider;
  TextEditingController searchController = TextEditingController();
  SearchResult<Review>? reviews;
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

      var result = await reviewProvider.get(filter: filter);
      setState(() {
        reviews = result;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching reviews: $e");
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error loading reviews: $e")));
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
      await _performSearch();
    });
  }

  Widget _buildReviewCard(Review review) {
    ImageProvider? driverImageProvider;
    if (review.driverPicture != null && review.driverPicture!.isNotEmpty) {
      try {
        driverImageProvider = MemoryImage(base64Decode(review.driverPicture!));
      } catch (e) {
        driverImageProvider = null;
      }
    }
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReviewDetailsScreen(review: review),
            ),
          ).then((_) {
            // Refresh review list when returning from review details
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
                  // Driver avatar
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.orange.shade100,
                    backgroundImage: driverImageProvider,
                    child: driverImageProvider == null
                        ? Icon(Icons.person, color: Colors.orange, size: 24)
                        : null,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review.driverFullName ?? 'Unknown Driver',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Rating stars
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < review.rating ? Icons.star : Icons.star_border,
                        color: Colors.orange,
                        size: 20,
                      );
                    }),
                  ),
                ],
              ),
              SizedBox(height: 12),
              // Comment
              if (review.comment != null && review.comment!.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    review.comment!,
                    style: TextStyle(fontSize: 14, color: Colors.grey[800]),
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
      body: Column(
        children: [
          // Search bar and New Review button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: customTextFieldDecoration(
                      "Search reviews",
                      prefixIcon: Icons.search,
                    ),
                    onChanged: (value) {
                      setState(() => _searchText = value);
                      _performSearch();
                    },
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DriveSelectionScreen(),
                      ),
                    ).then((_) {
                      // Refresh review list when returning from drive selection
                      _performSearch();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "New Review",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          // Reviews list
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : reviews == null || reviews!.items?.isEmpty == true
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.rate_review_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          "No reviews found",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Reviews from your rides will appear here",
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
                      itemCount: reviews!.items?.length ?? 0,
                      itemBuilder: (context, index) {
                        return _buildReviewCard(reviews!.items![index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
