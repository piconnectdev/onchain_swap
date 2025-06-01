import 'package:on_chain_swap/src/providers/skip_go/core/core/core.dart';
import 'package:on_chain_swap/src/providers/skip_go/core/core/methods.dart';
import 'package:on_chain_swap/src/providers/skip_go/models/types/types.dart';

/// This supports cross-chain actions among EVM chains, Cosmos chains, and between them.
/// Returns minimal number of messages required to execute a multi-chain swap or transfer.
/// This is a convenience endpoint that combines /route and /msgs into a single call.
class SkipGoApiRequestMsgsDirect
    extends SkipGoApiPostRequest<SkipGoApiMsgsDirect, Map<String, dynamic>> {
  /// Denom of the source asset
  final String sourceAssetDenom;

  /// Chain-id of the source asset
  final String sourceAssetChainId;

  /// Denom of the destination asset
  final String destAssetDenom;

  /// Chain-id of the destination asset
  final String destAssetChainId;

  /// Amount of source asset to be transferred or swapped
  final String amountIn;

  /// Amount of destination asset out
  final String amountOut;

  /// Map of chain-ids to receipient and/or sender address for each chain in the path.
  /// Since the path is not known to the caller beforehand, the caller
  /// should attempt to provide addresses for all chains in the path, and the
  /// API will return an error if the path cannot be constructed.
  final List<Map<String, String>> chainIdsToAddresses;

  /// Swap venues to consider, if provided (optional)
  /// A venue on which swaps can be exceuted
  final List<SkipGoApiVenue>? swapVenues;

  /// Percent tolerance for slippage on swap, if a swap is performed
  final String? slippageTolerancePercent;

  /// Number of seconds for the IBC transfer timeout, defaults to 5 minutes
  final String? timeoutSeconds;

  /// Map of chain-ids to arrays of affiliates.
  /// The API expects all chains to have the same cumulative affiliate fee
  /// bps for each chain specified. If any of the provided affiliate
  /// arrays does not have the same cumulative fee, the API will return an error.
  final Map<String, SkipGoApiChainAffiliates>? chainIdsToAffiliates;
  final SkipGoApiPostRouteHandler? postRouteHandler;

  /// Whether to allow route responses requiring multiple transactions
  final bool? allowMultiTx;

  /// Toggles whether the api should return routes that fail price safety checks.
  final bool? allowUnsafe;

  /// Array of experimental features to enable
  final List<String>? experimentalFeatures;

  /// Array of bridges to use
  final List<SkipGoApiBridgeType>? bridges;

  /// Indicates whether this transfer route should be relayed via Skip's Smart Relay service
  final bool? smartRelay;

  final SkipGoApiSmartSwapOptions? smartSwapOptions;

  /// Whether to allow swaps in the route
  final bool? allowSwaps;

  /// Whether to enable Go Fast routes
  final bool? goFast;

  /// Whether to enable gas warnings for intermediate and destination chains
  final bool? enableGasWarnings;

  SkipGoApiRequestMsgsDirect({
    required this.sourceAssetDenom,
    required this.sourceAssetChainId,
    required this.destAssetDenom,
    required this.destAssetChainId,
    required this.amountIn,
    required this.amountOut,
    this.slippageTolerancePercent,
    required this.timeoutSeconds,
    this.postRouteHandler,
    this.chainIdsToAffiliates,
    this.enableGasWarnings,
    required this.chainIdsToAddresses,
    this.swapVenues,
    this.allowMultiTx,
    this.allowUnsafe,
    this.experimentalFeatures,
    this.bridges,
    this.smartRelay,
    this.smartSwapOptions,
    this.allowSwaps,
    this.goFast,
  });
  @override
  String get method => SkipGoApiMethods.msgsDirect.url;

  @override
  Map<String, dynamic> body() {
    return {
      "amount_in": amountIn,
      "amount_out": amountOut,
      "source_asset_denom": sourceAssetDenom,
      "source_asset_chain_id": sourceAssetChainId,
      "dest_asset_denom": destAssetDenom,
      "dest_asset_chain_id": destAssetChainId,
      "chain_ids_to_addresses": chainIdsToAddresses,
      "slippage_tolerance_percent": slippageTolerancePercent,
      "timeout_seconds": timeoutSeconds,
      "swap_venues": swapVenues?.map((e) => e.toJson()).toList(),
      "post_route_handler": postRouteHandler?.toJson(),
      "chain_ids_to_affiliates":
          chainIdsToAffiliates?.map((k, v) => MapEntry(k, v.toJson())),
      "enable_gas_warnings": enableGasWarnings,
      "allow_multi_tx": allowMultiTx,
      "allow_unsafe": allowUnsafe,
      "experimental_features": experimentalFeatures,
      "bridges": bridges?.map((e) => e.name).toList(),
      "smart_relay": smartRelay,
      "smart_swap_options": smartSwapOptions?.toJson(),
      "allow_swaps": allowSwaps,
      "go_fast": goFast,
    };
  }

  @override
  SkipGoApiMsgsDirect onResonse(Map<String, dynamic> result) {
    return SkipGoApiMsgsDirect.fromJson(result);
  }
}
