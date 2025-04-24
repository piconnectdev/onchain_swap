import 'package:onchain_swap/src/providers/cf/core/core.dart';
import 'package:onchain_swap/src/providers/cf/models/models/rpc.dart';

class CfRPCRequestBoostPoolPendingFees
    extends CfRPCRequestParam<List<BoostPoolPendingFeesResponse>, List> {
  final UncheckedAssetAndChain? asset;
  const CfRPCRequestBoostPoolPendingFees({this.asset});
  @override
  List get params => [asset?.toJson()];
  @override
  String get method => "cf_boost_pool_pending_fees";

  @override
  List<BoostPoolPendingFeesResponse> onResonse(List result) {
    return result.map((e) => BoostPoolPendingFeesResponse.fromJson(e)).toList();
  }
}
