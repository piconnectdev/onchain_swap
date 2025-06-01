import 'package:on_chain_swap/src/providers/cf/core/core.dart';
import 'package:on_chain_swap/src/providers/cf/models/models/rpc.dart';

class CfRPCRequestIngressEgressEnvironment
    extends CfRPCRequestParam<IngressEgressEnvironment, Map<String, dynamic>> {
  @override
  String get method => "cf_ingress_egress_environment";

  @override
  IngressEgressEnvironment onResonse(Map<String, dynamic> result) {
    return IngressEgressEnvironment.fromJson(result);
  }
}
