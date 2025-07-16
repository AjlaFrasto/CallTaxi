import 'package:calltaxi_desktop_admin/model/brand.dart';
import 'package:calltaxi_desktop_admin/providers/base_provider.dart';

class BrandProvider extends BaseProvider<Brand> {
  BrandProvider() : super("Brand");

  @override
  Brand fromJson(dynamic json) {
    return Brand.fromJson(json);
  }
}
