import 'package:on_chain_swap/src/providers/swap_kit/core/core.dart';
import 'package:on_chain_swap/src/providers/swap_kit/models/types.dart';

/// Request a trade quote
class SwapKitRequestQuote
    extends SwapKitPostRequest<SwapKitRouteResponse, Map<String, dynamic>> {
  /// The asset being sold (e.g. "ETH.ETH").
  final String sellAsset;

  /// The asset being bought (e.g. "BTC.BTC")
  final String buyAsset;

  /// Amount in basic units (decimals separated with a dot).
  final String sellAmount;

  /// Limits the possible liquidity providers
  final List<String>? providers;

  /// Address of the sender.
  final String sourceAddress;

  /// Address of the recipient.
  final String destinationAddress;

  /// Max slippage in percentage (5 = 5%)
  final int? slippage;

  /// Affiliate address for revenue sharing
  final String? affiliate;

  /// Fee percentage in basis points (50= 0.5%)
  final int? affiliateFee;

  /// Allow smart contract as sender
  final bool? allowSmartContractSender;

  /// Allow smart contract as receiver.
  final bool? allowSmartContractReceiver;

  /// Bypass security checks.
  final bool? disableSecurityChecks;

  /// Include transaction details in the response
  final bool? includeTx;

  /// Enables Chainflip boost for better rates.
  final bool? cfBoost;
  const SwapKitRequestQuote(
      {required this.sellAsset,
      required this.buyAsset,
      required this.sellAmount,
      this.providers,
      required this.sourceAddress,
      required this.destinationAddress,
      this.slippage,
      this.affiliate,
      this.affiliateFee,
      this.allowSmartContractSender,
      this.allowSmartContractReceiver,
      this.disableSecurityChecks,
      this.includeTx,
      this.cfBoost});
  @override
  String get method => SwapKitMethods.quote.url;

  @override
  SwapKitRouteResponse onResonse(Map<String, dynamic> result) {
    return SwapKitRouteResponse.fromJson(result);
  }

  @override
  Map<String, dynamic> body() {
    return {
      'sellAsset': sellAsset,
      'buyAsset': buyAsset,
      'sellAmount': sellAmount,
      'providers': providers,
      'sourceAddress': sourceAddress,
      'destinationAddress': destinationAddress,
      'slippage': slippage,
      'affiliate': affiliate,
      'affiliateFee': affiliateFee,
      'allowSmartContractSender': allowSmartContractSender,
      'allowSmartContractReceiver': allowSmartContractReceiver,
      'disableSecurityChecks': disableSecurityChecks,
      'includeTx': includeTx,
      'cfBoost': cfBoost,
    }..removeWhere((k, v) => v == null);
  }
}
