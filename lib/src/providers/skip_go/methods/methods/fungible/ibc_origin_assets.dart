import 'package:onchain_swap/src/providers/skip_go/core/core/core.dart';
import 'package:onchain_swap/src/providers/skip_go/core/core/methods.dart';
import 'package:onchain_swap/src/providers/skip_go/models/types/types.dart';
import 'package:onchain_swap/src/utils/extensions/json.dart';

/// Get origin assets from a given list of denoms and chain IDs.
class SkipGoApiRequestIbcOriginAssets extends SkipGoApiPostRequest<
    List<SkipGoApiIbcOriginAsset>, Map<String, dynamic>> {
  /// Array of assets to get origin assets for
  final List<SkipGoApiIbcOriginAssetParam> assets;
  SkipGoApiRequestIbcOriginAssets(this.assets);
  @override
  String get method => SkipGoApiMethods.ibcOriginAssets.url;

  @override
  Map<String, dynamic> body() {
    return {"assets": assets.map((e) => e.toJson()).toList()};
  }

  @override
  List<SkipGoApiIbcOriginAsset> onResonse(Map<String, dynamic> result) {
    return result
        .asListOfMap("origin_assets")!
        .map(SkipGoApiIbcOriginAsset.fromJson)
        .toList();
  }
}
