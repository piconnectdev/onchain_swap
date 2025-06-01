import 'package:on_chain_swap/src/providers/swap_kit/core/core.dart';
import 'package:on_chain_swap/src/providers/swap_kit/models/types.dart';

/// The /tracker endpoint provides real-time status information for a specific transaction.
/// It is particularly useful for tracking the progress and details of swaps, transfers,
/// and other operations. To use this endpoint, you must provide the chain ID and transaction hash.
/// For a complete list of chain IDs used by SwapKit you can
class SwapKitRequestTrack
    extends SwapKitPostRequest<SwapKitTrack, Map<String, dynamic>> {
  /// Transaction hash
  final String hash;

  /// Chain ID of the transaction
  final String chainId;
  final int block;
  const SwapKitRequestTrack(
      {required this.hash, this.block = 0, required this.chainId});
  @override
  String get method => SwapKitMethods.track.url;

  @override
  SwapKitTrack onResonse(Map<String, dynamic> result) {
    return SwapKitTrack.fromJson(result);
  }

  @override
  Map<String, dynamic> body() {
    return {"hash": hash, "chainId": chainId, "block": block};
  }
}
