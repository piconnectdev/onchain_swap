import 'package:onchain_swap/src/providers/cf/core/core.dart';
import 'package:onchain_swap/src/providers/cf/models/models/rpc.dart';

class CfRPCRequestPoolOrders
    extends CfRPCRequestParam<PoolOrdersResponse, Map<String, dynamic>> {
  final UncheckedAssetAndChain fromAsset;
  final UncheckedAssetAndChain toAsset;
  final String? accountId;
  const CfRPCRequestPoolOrders(
      {required this.fromAsset, required this.toAsset, this.accountId});

  @override
  List get params => [fromAsset.toJson(), toAsset.toJson(), accountId];

  @override
  String get method => "cf_pool_orders";

  @override
  PoolOrdersResponse onResonse(Map<String, dynamic> result) {
    return PoolOrdersResponse.fromJson(result);
  }
}
