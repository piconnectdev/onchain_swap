import 'package:blockchain_utils/service/models/params.dart';
import 'package:onchain_swap/src/swap/types/types.dart';

abstract class SwapService<
    ASSET extends BaseSwapAsset,
    PROVIDER extends BaseProvider,
    ROUTE extends SwapRoute,
    QUOTE extends QuoteSwapParams<ASSET>> {
  final SwapServiceType service;
  final PROVIDER provider;
  const SwapService({required this.service, required this.provider});
  Future<List<ROUTE>> createRoutes(QUOTE params);
  Future<List<ASSET>> loadAssets();
  Map<SwapNetwork, Set<BaseSwapAsset>> getDestAssets(BaseSwapAsset asset);
}
