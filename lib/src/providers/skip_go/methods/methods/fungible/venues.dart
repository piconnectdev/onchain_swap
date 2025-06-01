import 'package:onchain_swap/src/providers/skip_go/core/core/core.dart';
import 'package:onchain_swap/src/providers/skip_go/core/core/methods.dart';
import 'package:onchain_swap/src/providers/skip_go/models/types/types.dart';
import 'package:onchain_swap/src/utils/extensions/json.dart';

/// Get supported swap venues.
class SkipGoApiRequestVenues
    extends SkipGoApiGetRequest<List<SkipGoApiVenue>, Map<String, dynamic>> {
  /// Whether to display only venues from testnets in the response
  final bool? onlyTestnets;
  SkipGoApiRequestVenues({this.onlyTestnets});
  @override
  String get method => SkipGoApiMethods.venues.url;

  @override
  Map<String, dynamic> get queryParameters => {"only_testnets": onlyTestnets};
  @override
  List<SkipGoApiVenue> onResonse(Map<String, dynamic> result) {
    return result
        .as<List>("venues")
        .map((e) => SkipGoApiVenue.fromJson(e))
        .toList();
  }
}
