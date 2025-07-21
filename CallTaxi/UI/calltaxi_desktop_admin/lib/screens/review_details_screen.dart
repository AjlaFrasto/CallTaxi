import 'package:calltaxi_desktop_admin/layouts/master_screen.dart';
import 'package:calltaxi_desktop_admin/model/review.dart';
import 'package:flutter/material.dart';
import '../utils/custom_map_view.dart';

class ReviewDetailsScreen extends StatelessWidget {
  final Review review;
  const ReviewDetailsScreen({super.key, required this.review});

  Widget _buildInfoRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: Colors.orange),
            SizedBox(width: 8),
          ],
          Text(
            "$label:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarRating(int rating) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 22,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Review Details",
      showBackButton: true,
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 1000),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 24.0,
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Map on the left
                    SizedBox(
                      width: 420,
                      child: CustomMapView(
                        start: review.startLocation,
                        end: review.endLocation,
                        height: 400,
                        width: 420,
                      ),
                    ),
                    SizedBox(width: 32),
                    // Details on the right
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 400,
                            minHeight: 0,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: _buildInfoRow(
                                      "User",
                                      review.userFullName ?? '-',
                                      icon: Icons.person,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: _buildInfoRow(
                                      "Driver",
                                      review.driverFullName ?? '-',
                                      icon: Icons.drive_eta,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Center(child: _buildStarRating(review.rating)),
                              SizedBox(height: 16),
                              Text(
                                "Comment",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 8),
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.orange,
                                    width: 1,
                                  ),
                                ),
                                constraints: BoxConstraints(minHeight: 60),
                                child: Text(
                                  review.comment ?? '-',
                                  style: TextStyle(fontSize: 15),
                                  softWrap: true,
                                ),
                              ),
                              SizedBox(height: 18),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  "Reviewed on: ${review.createdAt.toString().split(' ')[0]}",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
