import 'package:onchain_swap/src/providers/cf/core/core.dart';
import 'package:onchain_swap/src/providers/cf/models/models/rpc.dart';

class CfRPCRequestEnvironment
    extends CfRPCRequestParam<Environment, Map<String, dynamic>> {
  @override
  String get method => "cf_environment";

  @override
  Environment onResonse(Map<String, dynamic> result) {
    return Environment.fromJson(result);
  }
}
