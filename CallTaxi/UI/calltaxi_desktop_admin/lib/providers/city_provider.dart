
import 'package:calltaxi_desktop_admin/model/city.dart';
import 'package:calltaxi_desktop_admin/providers/base_provider.dart';


class CityProvider extends BaseProvider<City> {
  CityProvider() : super("City");

  @override
  City fromJson(dynamic json) {
    return City.fromJson(json);
  }

}
