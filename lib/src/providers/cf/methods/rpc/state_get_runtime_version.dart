import 'package:on_chain_swap/src/providers/cf/core/core.dart';
import 'package:on_chain_swap/src/providers/cf/models/models/rpc.dart';

class CfRPCRequestStateGetRuntimeVersion
    extends CfRPCRequestParam<RuntimeVersionResponse, Map<String, dynamic>> {
  @override
  String get method => "state_getRuntimeVersion";

  @override
  RuntimeVersionResponse onResonse(Map<String, dynamic> result) {
    return RuntimeVersionResponse.fromJson(result);
  }
}
