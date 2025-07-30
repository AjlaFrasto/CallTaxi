import 'package:flutter/material.dart';
import 'package:calltaxi_mobile_client/model/review.dart';
import 'package:calltaxi_mobile_client/model/driver_request.dart';
import 'package:calltaxi_mobile_client/providers/review_provider.dart';
import 'package:calltaxi_mobile_client/providers/user_provider.dart';
// import 'package:calltaxi_mobile_client/utils/custom_map_view.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class ReviewDetailsScreen extends StatefulWidget {
  final Review? review; // For viewing existing review
  final DriverRequest? driveRequest; // For creating new review
  final bool isNewReview;

  const ReviewDetailsScreen({
    super.key,
    this.review,
    this.driveRequest,
    this.isNewReview = false,
  });

  @override
  State<ReviewDetailsScreen> createState() => _ReviewDetailsScreenState();
}

class _ReviewDetailsScreenState extends State<ReviewDetailsScreen> {
  late ReviewProvider reviewProvider;
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      reviewProvider = Provider.of<ReviewProvider>(context, listen: false);

      // If viewing existing review, populate the form
      if (widget.review != null) {
        setState(() {
          _rating = widget.review!.rating;
          _commentController.text = widget.review!.comment ?? '';
        });
      }
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please select a rating")));
      return;
    }

    if (UserProvider.currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("User not found")));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      var reviewData = {
        "driveRequestId":
            widget.driveRequest?.id ?? widget.review!.driveRequestId,
        "userId": UserProvider.currentUser!.id,
        "rating": _rating,
        "comment": _commentController.text.trim(),
      };

      if (widget.review != null) {
        // Update existing review
        await reviewProvider.update(widget.review!.id, reviewData);
      } else {
        // Create new review
        await reviewProvider.insert(reviewData);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.review != null
                ? "Review updated successfully"
                : "Review submitted successfully",
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _rating = index + 1;
            });
          },
          child: Icon(
            index < _rating ? Icons.star : Icons.star_border,
            color: Colors.orange,
            size: 40,
          ),
        );
      }),
    );
  }

  Widget _buildReviewForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.review != null ? 'Edit your review' : 'Rate your experience',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 16),
        _buildStarRating(),
        SizedBox(height: 24),
        Text(
          'Comment (optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _commentController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Share your experience...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.orange, width: 2),
            ),
          ),
        ),
        SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitReview,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSubmitting
                ? CircularProgressIndicator(color: Colors.white)
                : Text(
                    widget.review != null ? 'Update Review' : 'Submit Review',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // When editing, we might not have driveRequest, so we need to handle that
    final driveRequest = widget.driveRequest;
    final isEditing = widget.review != null;

    if (driveRequest == null && !isEditing) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Review Details'),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
        body: Center(child: Text('No drive information available')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.review != null ? 'Edit Review' : 'Write Review'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drive information (only show if we have driveRequest)
            if (driveRequest != null)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Drive Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.local_taxi,
                            color: Colors.orange,
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Drive #${driveRequest.id.toString().padLeft(6, '0')}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (driveRequest.driverFullName != null)
                                  Text(
                                    'Driver: ${driveRequest.driverFullName}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${driveRequest.finalPrice.toStringAsFixed(2)} KM',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              Text(
                                '${driveRequest.distance.toStringAsFixed(1)} km',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
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
            if (driveRequest != null) SizedBox(height: 24),

            // Review section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildReviewForm(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
