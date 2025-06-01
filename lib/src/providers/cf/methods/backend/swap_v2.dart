import 'package:on_chain_swap/src/providers/cf/core/core.dart';
import 'package:on_chain_swap/src/providers/cf/core/swap.dart';
import 'package:on_chain_swap/src/providers/cf/models/models/v2.dart';

class CfBackendRequestSwapStatusV2
    extends CfBackendRequestParam<SwapStatusResponseV2, Map<String, dynamic>> {
  final String id;
  const CfBackendRequestSwapStatusV2(this.id);
  @override
  Map<String, String?>? get queryParameters => {};

  @override
  String get method => CfSwapMethods.swapV2.url;

  @override
  List<String> get pathParameters => [id];

  @override
  SwapStatusResponseV2 onResonse(Map<String, dynamic> result) {
    return SwapStatusResponseV2.fromJson(result);
  }
}
