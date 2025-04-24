import 'package:onchain_swap/src/providers/skip_go/core/core/core.dart';
import 'package:onchain_swap/src/providers/skip_go/core/core/methods.dart';
import 'package:onchain_swap/src/providers/skip_go/models/types/types.dart';
import 'package:onchain_swap/src/utils/extensions/json.dart';

/// Get the status of the specified transaction and any subsequent IBC or Axelar
/// transfers if routing assets cross chain. The transaction must have previously
/// been submitted to either the /submit or /track endpoints.
class SkipGoApiRequestStatus
    extends SkipGoApiGetRequest<List<SkipGoApiTransfer>, Map<String, dynamic>> {
  /// Hex encoded hash of the transaction to query for
  final String txHash;

  /// Chain ID of the transaction
  final String chainId;
  SkipGoApiRequestStatus({required this.txHash, required this.chainId});
  @override
  String get method => SkipGoApiMethods.status.url;

  @override
  Map<String, dynamic> get queryParameters =>
      {"tx_hash": txHash, "chain_id": chainId};

  @override
  List<SkipGoApiTransfer> onResonse(Map<String, dynamic> result) {
    return result
        .asListOfMap("transfers")!
        .map((e) => SkipGoApiTransfer.fromJson(e))
        .toList();
  }
}
