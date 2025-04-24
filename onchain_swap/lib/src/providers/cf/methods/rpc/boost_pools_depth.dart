import 'package:onchain_swap/src/providers/cf/core/core.dart';
import 'package:onchain_swap/src/providers/cf/models/models/rpc.dart';

class CfRPCRequestBoostPoolsDepth extends CfRPCRequestParam<
    List<BoostPoolDepthResponse>, List<Map<String, dynamic>>> {
  @override
  String get method => "cf_boost_pools_depth";
  @override
  List<BoostPoolDepthResponse> onResonse(List result) {
    return result.map((e) => BoostPoolDepthResponse.fromJson(e)).toList();
  }
}
