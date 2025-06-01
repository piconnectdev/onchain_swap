import 'package:on_chain_swap/src/providers/cf/core/core.dart';
import 'package:on_chain_swap/src/providers/cf/models/models/rpc.dart';

class CfRPCRequestFundingEnvironment
    extends CfRPCRequestParam<FundingEnvironment, Map<String, dynamic>> {
  @override
  String get method => "cf_funding_environment";

  @override
  FundingEnvironment onResonse(Map<String, dynamic> result) {
    return FundingEnvironment.fromJson(result);
  }
}
