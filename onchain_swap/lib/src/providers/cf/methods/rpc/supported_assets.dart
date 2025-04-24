import 'package:onchain_swap/src/providers/cf/core/core.dart';
import 'package:onchain_swap/src/providers/cf/models/models/rpc.dart';

class CfRPCRequestSupportAssets
    extends CfRPCRequestParam<List<AssetAndChain>, List<Map<String, dynamic>>> {
  @override
  String get method => "cf_supported_assets";

  @override
  List<AssetAndChain> onResonse(List<Map<String, dynamic>> result) {
    return result.map((e) => AssetAndChain.fromJson(e)).toList();
  }
}
