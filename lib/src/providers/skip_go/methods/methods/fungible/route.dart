import 'package:on_chain_swap/src/providers/skip_go/core/core/core.dart';
import 'package:on_chain_swap/src/providers/skip_go/core/core/methods.dart';
import 'package:on_chain_swap/src/providers/skip_go/models/types/types.dart';

/// This supports cross-chain actions among EVM chains, Cosmos chains, and between them.
/// Returns the sequence of transfers and/or swaps to reach the given destination asset
/// from the given source asset, along with estimated amount out. Commonly called
/// before /msgs to generate route info and quote.
class SkipGoApiRequestRoute
    extends SkipGoApiPostRequest<SkipGoApiRoute, Map<String, dynamic>> {
  /// Amount of source asset to be transferred or swapped. Only one of amount_in and amount_out should be provided.
  final String? amountIn;

  /// Amount of destination asset to receive. Only one of amount_in and amount_out should be provided.
  /// If amount_out is provided for a swap, the route will be computed to give exactly amount_out.
  final String? amountOut;

  /// Denom of the source asset
  final String sourceAssetDenom;

  /// Chain-id of the source asset
  final String sourceAssetChainId;

  /// Denom of the destination asset
  final String destAssetDenom;

  /// Chain-id of the destination asset
  final String destAssetChainId;

  /// Cumulative fee to be distributed to affiliates, in bps (optional)
  final String? cumulativeAffiliateFeeBps;

  /// Swap venues to consider, if provided (optional)
  /// A venue on which swaps can be exceuted
  final List<SkipGoApiVenue>? swapVenues;

  /// Whether to allow route responses requiring multiple transactions
  final bool? allowMultiTx;

  /// Toggles whether the api should return routes that fail price safety checks.
  final bool? allowUnsafe;

  /// Array of experimental features to enable
  final List<String>? experimentalFeatures;

  /// Array of bridges to use Bridge Type
  final List<SkipGoApiBridgeType>? bridges;

  /// Indicates whether this transfer route should be relayed via Skip's Smart Relay service - true by default.
  final bool? smartRelay;
  final SkipGoApiSmartSwapOptionsParams? smartSwapOptions;

  /// Whether to allow swaps in the route
  final bool? allowSwaps;

  /// Whether to enable Go Fast routes
  final bool? goFast;

  SkipGoApiRequestRoute.givenIn(
      {required this.sourceAssetDenom,
      required this.sourceAssetChainId,
      required this.destAssetDenom,
      required this.destAssetChainId,
      required String this.amountIn,
      this.cumulativeAffiliateFeeBps,
      this.swapVenues,
      this.allowMultiTx,
      this.allowUnsafe,
      this.experimentalFeatures,
      this.bridges,
      this.smartRelay,
      this.smartSwapOptions,
      this.allowSwaps,
      this.goFast})
      : amountOut = null;

  SkipGoApiRequestRoute.givenOut(
      {required this.sourceAssetDenom,
      required this.sourceAssetChainId,
      required this.destAssetDenom,
      required this.destAssetChainId,
      required String this.amountOut,
      this.cumulativeAffiliateFeeBps,
      this.swapVenues,
      this.allowMultiTx,
      this.allowUnsafe,
      this.experimentalFeatures,
      this.bridges,
      this.smartRelay,
      this.smartSwapOptions,
      this.allowSwaps,
      this.goFast})
      : amountIn = null;
  @override
  String get method => SkipGoApiMethods.route.url;

  @override
  Map<String, dynamic> body() {
    return {
      "amount_in": amountIn,
      "amount_out": amountOut,
      "source_asset_denom": sourceAssetDenom,
      "source_asset_chain_id": sourceAssetChainId,
      "dest_asset_denom": destAssetDenom,
      "dest_asset_chain_id": destAssetChainId,
      "cumulative_affiliate_fee_bps": cumulativeAffiliateFeeBps,
      "swap_venues": swapVenues?.map((e) => e.toJson()).toList(),
      "allow_multi_tx": allowMultiTx,
      "allow_unsafe": allowUnsafe,
      "experimental_features": experimentalFeatures,
      "bridges": bridges?.map((e) => e.name).toList(),
      "smart_relay": smartRelay,
      "smart_swap_options": smartSwapOptions?.toJson(),
      "allow_swaps": allowSwaps,
      "go_fast": goFast
    };
  }

  @override
  SkipGoApiRoute onResonse(Map<String, dynamic> result) {
    return SkipGoApiRoute.fromJson(result);
  }
}
