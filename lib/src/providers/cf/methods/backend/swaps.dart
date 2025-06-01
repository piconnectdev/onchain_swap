import 'package:onchain_swap/src/providers/cf/core/core.dart';
import 'package:onchain_swap/src/providers/cf/core/swap.dart';
import 'package:onchain_swap/src/providers/cf/models/models/backend.dart';

class CfBackendRequestSwapStatus
    extends CfBackendRequestParam<VaultSwapResponse2, Map<String, dynamic>> {
  final String id;
  const CfBackendRequestSwapStatus(this.id);
  @override
  Map<String, String?>? get queryParameters => {};

  @override
  String get method => CfSwapMethods.swap.url;

  @override
  List<String> get pathParameters => [id];

  @override
  VaultSwapResponse2 onResonse(Map<String, dynamic> result) {
    return VaultSwapResponse2.fromJson(result);
  }
}
