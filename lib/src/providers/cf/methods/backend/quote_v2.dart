import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_swap/src/providers/cf/core/core.dart';
import 'package:on_chain_swap/src/providers/cf/core/swap.dart';
import 'package:on_chain_swap/src/providers/cf/models/models/backend.dart';

class CfBackendRequestQuoteV2
    extends CfBackendRequestParam<List<QuoteQueryResponse>, List> {
  CfBackendRequestQuoteV2(
      {required this.srcChain,
      required this.srcAsset,
      required this.destChain,
      required this.destAsset,
      required this.amount,
      this.dcaEnabled = false,
      this.isVaultSwap,
      this.brokerCommissionBps,
      List<AffiliateBroker>? affiliateBrokers})
      : affiliateBrokers = affiliateBrokers?.immutable;
  final String srcChain;
  final String srcAsset;
  final String destChain;
  final String destAsset;
  final String amount;
  final int? brokerCommissionBps;
  final List<AffiliateBroker>? affiliateBrokers;
  final bool dcaEnabled;
  final bool? isVaultSwap;
  @override
  Map<String, dynamic>? get queryParameters => {
        "amount": amount,
        "srcChain": srcChain,
        "srcAsset": srcAsset,
        "destChain": destChain,
        "destAsset": destAsset,
        "brokerCommissionBps": brokerCommissionBps?.toString(),
        "dcaEnabled": dcaEnabled.toString(),
        "isVaultSwap": isVaultSwap?.toString(),
        "affiliateBrokers":
            affiliateBrokers?.map((e) => e.toJson()).toList().toString(),
      }..removeWhere((k, v) => v == null);

  @override
  String get method => CfSwapMethods.quoteV2.url;

  @override
  List<String> get pathParameters => [];
  @override
  List<QuoteQueryResponse> onResonse(List result) {
    return result.map((e) => QuoteQueryResponse.fromJson(e)).toList();
  }
}
