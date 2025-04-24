import 'package:onchain_swap/src/providers/cf/core/core.dart';
import 'package:onchain_swap/src/providers/cf/models/models/rpc.dart';

class CfRPCRequestPoolsEnvironment
    extends CfRPCRequestParam<PoolsEnvironment, Map<String, dynamic>> {
  @override
  String get method => "cf_pools_environment";

  @override
  PoolsEnvironment onResonse(Map<String, dynamic> result) {
    return PoolsEnvironment.fromJson(result);
  }
}
