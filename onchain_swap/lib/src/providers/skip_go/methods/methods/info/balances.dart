import 'package:onchain_swap/src/providers/skip_go/core/core/core.dart';
import 'package:onchain_swap/src/providers/skip_go/core/core/methods.dart';
import 'package:onchain_swap/src/providers/skip_go/models/types/types.dart';

/// Get the balances of a given set of assets on a given chain and wallet address.
/// Compatible with all Skip Go-supported assets, excluding CW20 assets, across SVM, EVM, and Cosmos chains.
class SkipGoApiRequestBalances
    extends SkipGoApiPostRequest<SkipGoApiBalanceChains, Map<String, dynamic>> {
  final List<SkipGoApiBalancesParams> chains;
  const SkipGoApiRequestBalances(this.chains);
  @override
  String get method => SkipGoApiMethods.balances.url;

  @override
  SkipGoApiBalanceChains onResonse(Map<String, dynamic> result) {
    return SkipGoApiBalanceChains.fromJson(result);
  }

  @override
  Map<String, dynamic> body() {
    return {
      "chains": {for (final i in chains) ...i.toJson()}
    };
  }
}
