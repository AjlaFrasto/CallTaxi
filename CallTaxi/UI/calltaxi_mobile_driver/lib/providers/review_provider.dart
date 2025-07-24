import 'package:calltaxi_desktop_admin/model/review.dart';
import 'package:calltaxi_desktop_admin/providers/base_provider.dart';

class ReviewProvider extends BaseProvider<Review> {
  ReviewProvider() : super("Review");

  @override
  Review fromJson(dynamic json) {
    return Review.fromJson(json);
  }
}
