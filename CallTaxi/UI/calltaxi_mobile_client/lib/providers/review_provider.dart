import 'package:calltaxi_mobile_client/model/review.dart';
import 'package:calltaxi_mobile_client/providers/base_provider.dart';

class ReviewProvider extends BaseProvider<Review> {
  ReviewProvider() : super("Review");

  @override
  Review fromJson(dynamic json) {
    return Review.fromJson(json);
  }
}
