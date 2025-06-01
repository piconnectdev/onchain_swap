import 'package:blockchain_utils/helper/helper.dart';
import 'package:onchain_swap/src/swap/services/thor/thor.dart';
import 'package:onchain_swap/src/swap/types/types.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'constants.dart';

class MayaSwapService extends ThorSwapService {
  MayaSwapService({required ThorNodeProvider provider})
      : super(service: SwapServiceType.maya, provider: provider);

  @override
  Future<List<BaseSwapAsset>> loadAssets() async {
    return MayaSwapConstants.assets;
  }

  @override
  Map<SwapNetwork, Set<BaseSwapAsset>> getDestAssets(BaseSwapAsset asset) {
    final allAssets = MayaSwapConstants.assets;
    List<BaseSwapAsset> assets = [];
    if (asset.provider.service == service || allAssets.contains(asset)) {
      assets = allAssets.clone();
    }
    final Map<SwapNetwork, Set<BaseSwapAsset>> networkAssets = {};
    for (final i in assets) {
      networkAssets[i.network] ??= {};
      networkAssets[i.network]?.add(i);
    }
    return networkAssets;
  }
}
