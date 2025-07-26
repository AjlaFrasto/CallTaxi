import 'package:calltaxi_mobile_client/model/city.dart';
import 'package:calltaxi_mobile_client/providers/base_provider.dart';

class CityProvider extends BaseProvider<City> {
  CityProvider() : super("City");

  @override
  City fromJson(dynamic json) {
    return City.fromJson(json);
  }
}
