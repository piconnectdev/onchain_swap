import 'package:onchain_swap/src/providers/skip_go/core/core/core.dart';
import 'package:onchain_swap/src/providers/skip_go/core/core/methods.dart';
import 'package:onchain_swap/src/utils/extensions/json.dart';

/// Submit a signed base64 encoded transaction to be broadcast to the specified network.
/// On successful submission, the status of the transaction and any subsequent IBC or Axelar
/// transfers can be queried through the /status endpoint.
class SkipGoApiRequestSubmit
    extends SkipGoApiPostRequest<String, Map<String, dynamic>> {
  /// Signed base64 encoded transaction
  final String tx;

  /// Chain ID of the transaction
  final String chainId;
  SkipGoApiRequestSubmit({required this.tx, required this.chainId});
  @override
  String get method => SkipGoApiMethods.submit.url;

  @override
  Map<String, dynamic> body() {
    return {"tx": tx, "chain_id": chainId};
  }

  @override
  String onResonse(Map<String, dynamic> result) {
    return result.as("tx_hash");
  }
}
