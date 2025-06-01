import 'package:onchain_swap/src/providers/skip_go/core/core/core.dart';
import 'package:onchain_swap/src/providers/skip_go/core/core/methods.dart';
import 'package:onchain_swap/src/providers/skip_go/models/types/types.dart';

/// This supports cross-chain actions among EVM chains, Cosmos chains, and between them.
/// Returns minimal number of messages required to execute a multi-chain swap or transfer.
/// Input consists of the output of route with additional information required for
/// message construction (e.g. destination addresses for each chain)
class SkipGoApiRequestMsgs
    extends SkipGoApiPostRequest<SkipGoApiMsgs, Map<String, dynamic>> {
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

  /// Array of receipient and/or sender address for each chain in the path,
  /// corresponding to the chain_ids array returned from a route request
  final List<String> addressList;

  /// Array of operations required to perform the transfer or swap
  final List<SkipGoApiOperation> operations;

  /// Percent tolerance for slippage on swap, if a swap is performed
  final String? slippageTolerancePercent;

  /// Number of seconds for the IBC transfer timeout, defaults to 5 minutes
  final String? timeoutSeconds;

  final SkipGoApiPostRouteHandler? postRouteHandler;

  /// Map of chain-ids to arrays of affiliates.
  /// The API expects all chains to have the same cumulative affiliate fee
  /// bps for each chain specified. If any of the provided affiliate
  /// arrays does not have the same cumulative fee, the API will return an error.
  final Map<String, SkipGoApiChainAffiliates>? chainIdsToAffiliates;

  /// Whether to enable gas warnings for intermediate and destination chains
  final bool? enableGasWarnings;

  SkipGoApiRequestMsgs(
      {required this.sourceAssetDenom,
      required this.sourceAssetChainId,
      required this.destAssetDenom,
      required this.destAssetChainId,
      required this.amountIn,
      required this.amountOut,
      required this.addressList,
      required this.operations,
      this.slippageTolerancePercent,
      required this.timeoutSeconds,
      this.postRouteHandler,
      this.chainIdsToAffiliates,
      this.enableGasWarnings});
  @override
  String get method => SkipGoApiMethods.msgs.url;

  @override
  Map<String, dynamic> body() {
    return {
      "amount_in": amountIn,
      "amount_out": amountOut,
      "source_asset_denom": sourceAssetDenom,
      "source_asset_chain_id": sourceAssetChainId,
      "dest_asset_denom": destAssetDenom,
      "dest_asset_chain_id": destAssetChainId,
      "address_list": addressList,
      "operations": operations.map((e) => e.toJson()).toList(),
      "slippage_tolerance_percent": slippageTolerancePercent,
      "timeout_seconds": timeoutSeconds,
      "post_route_handler": postRouteHandler?.toJson(),
      "chain_ids_to_affiliates":
          chainIdsToAffiliates?.map((k, v) => MapEntry(k, v.toJson())),
      "enable_gas_warnings": enableGasWarnings
    };
  }

  @override
  SkipGoApiMsgs onResonse(Map<String, dynamic> result) {
    return SkipGoApiMsgs.fromJson(result);
  }
}
