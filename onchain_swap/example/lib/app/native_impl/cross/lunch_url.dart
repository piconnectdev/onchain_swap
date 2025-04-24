import 'package:example/app/native_impl/core/core.dart';

mixin LunchUrlImpl {
  static Future<bool> lunchUri(String uri) async {
    return await AppNativeMethods.platform.launchUri(uri);
  }
}
