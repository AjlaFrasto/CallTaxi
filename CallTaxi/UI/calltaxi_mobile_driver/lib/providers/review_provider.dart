import 'package:calltaxi_mobile_driver/model/review.dart';
import 'package:calltaxi_mobile_driver/providers/base_provider.dart';

class ReviewProvider extends BaseProvider<Review> {
  ReviewProvider() : super("Review");

  @override
  Review fromJson(dynamic json) {
    return Review.fromJson(json);
  }
}
