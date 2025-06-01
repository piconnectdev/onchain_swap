import 'package:on_chain_swap/src/providers/cf/core/core.dart';
import 'package:on_chain_swap/src/providers/cf/models/models/rpc.dart';

class CfRPCRequestSwappingEnvironment
    extends CfRPCRequestParam<SwappingEnvironment, Map<String, dynamic>> {
  @override
  String get method => "cf_swapping_environment";

  @override
  SwappingEnvironment onResonse(Map<String, dynamic> result) {
    return SwappingEnvironment.fromJson(result);
  }
}
