import 'package:calltaxi_mobile_driver/model/brand.dart';
import 'package:calltaxi_mobile_driver/providers/base_provider.dart';

class BrandProvider extends BaseProvider<Brand> {
  BrandProvider() : super("Brand");

  @override
  Brand fromJson(dynamic json) {
    return Brand.fromJson(json);
  }
}
