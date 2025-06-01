import 'package:onchain_swap_example/app/native_impl/cross/lunch_url.dart';

class UriUtils {
  static Future<bool> lunch(String? uri) async {
    if (uri == null) return false;
    return await LunchUrlImpl.lunchUri(uri);
  }
}
