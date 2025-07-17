import 'package:calltaxi_desktop_admin/model/user.dart';
import 'package:calltaxi_desktop_admin/providers/base_provider.dart';

class DriverProvider extends BaseProvider<User> {
  DriverProvider() : super("Users");

  @override
  User fromJson(dynamic json) {
    return User.fromJson(json);
  }
}
