import 'package:on_chain_swap/src/providers/cf/core/core.dart';

class CfRPCRequestStateGetMetadata extends CfRPCRequestParam<String, String> {
  @override
  String get method => "state_getMetadata";
}
