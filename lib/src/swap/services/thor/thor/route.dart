import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:onchain_swap/src/exception/exception.dart'
    show DartOnChainSwapPluginException;
import 'package:onchain_swap/src/swap/services/thor/thor/constants.dart';
import 'package:onchain_swap/src/swap/services/thor/thor/utils.dart';
import 'package:onchain_swap/src/swap/transaction/transaction.dart';
import 'package:onchain_swap/src/swap/types/types.dart';
import 'package:onchain_swap/src/swap/utils/utils.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:on_chain/ethereum/src/address/evm_address.dart';

class ThorQuoteSwapParams extends QuoteSwapParams<BaseSwapAsset> {
  final double tolerance;
  ThorQuoteSwapParams({
    required super.sourceAsset,
    required super.destinationAsset,
    required super.amount,
    super.sourceAddress,
    super.destinationAddress,
    this.tolerance = 15.0,
  });
  int get toleranceBps => (tolerance * 100).toInt();
}

class ThorSwapRoute extends SwapRoute<ThorQuoteSwapParams,
    SwapRouteGeneralTransactionBuilderParam> {
  final ThoreNodeQouteSwapResponse route;
  final int? interval;

  ThorSwapRoute(
      {required super.expireTime,
      required super.expectedAmount,
      required super.quote,
      required this.route,
      required super.estimateTime,
      required super.provider,
      required super.fees,
      required super.tolerance,
      required super.worstCaseAmount,
      required this.interval});
  @override
  ThorSwapRoute updateTolerance(double tolerance) {
    return ThorSwapRoute(
        expireTime: expireTime,
        expectedAmount: expectedAmount,
        quote: quote,
        route: route,
        estimateTime: estimateTime,
        worstCaseAmount: ThorSwapUtils.calculateWorstCaseAmount(
            expectedAmount: route.expectedAmountOut, tolranceBps: tolerance),
        provider: provider,
        fees: fees,
        tolerance: tolerance,
        interval: interval);
  }

  @override
  SwapRouteTransactionBuilder txBuilder(
      SwapRouteGeneralTransactionBuilderParam params) {
    final sourceNetwork = quote.sourceAsset.network;
    final destinationAddress = SwapUtils.validateNetworkAddress(
        quote.destinationAsset.network, params.destinationAddress);
    final memo = ThorSwapUtils.buildMemo(this, destinationAddress);
    switch (quote.sourceAsset.network.type) {
      case SwapChainType.ethereum:
        final ETHAddress source =
            SwapUtils.toNetworkAddress(sourceNetwork, params.sourceAddress);
        final network = quote.sourceAsset.network.cast<SwapEthereumNetwork>();
        final ETHAddress destination = ETHAddress(route.inboundAddress);

        if (quote.sourceAsset.isNative) {
          return SwapRouteEthereumTransactionBuilder(
              route: this,
              params: params,
              operations: [
                SwapRouteEthereumNativeTransactionOperation(
                    amount: quote.amount,
                    source: source,
                    destination: destination,
                    network: network,
                    memo: memo),
              ]);
        }
        final contract = SwapUtils.toNetworkAddress(
            sourceNetwork, quote.sourceAsset.identifier);
        final router = route.router;
        if (router == null) {
          throw const DartOnChainSwapPluginException("Invalid route address.");
        }
        final routerAddress = SwapUtils.toNetworkAddress(sourceNetwork, router);
        final ETHAddress inboundAddress =
            SwapUtils.toNetworkAddress(sourceNetwork, route.inboundAddress);

        return SwapRouteEthereumTransactionBuilder(
            route: this,
            params: params,
            operations: [
              SwapRouteEthereumAproveTransactionOperation(
                  amount: quote.amount,
                  source: source,
                  spender: routerAddress,
                  contract: contract,
                  network: network),
              SwapRouteEthereumCallContractTransactionOperation(
                  method: ThorSwapConstants.depositWithExpiry,
                  network: network,
                  source: source,
                  params: [
                    inboundAddress,
                    contract,
                    quote.amount.amount,
                    memo,
                    route.expiry
                  ],
                  contract: routerAddress),
            ]);

      case SwapChainType.bitcoin:
        final BitcoinNetworkAddress sourceAddress =
            SwapUtils.toNetworkAddress(sourceNetwork, params.sourceAddress);
        final BitcoinNetworkAddress destination =
            SwapUtils.toNetworkAddress(sourceNetwork, route.inboundAddress);
        return SwapRouteBitcoinTransactionBuilder(
            route: this,
            params: params,
            operations: [
              SwapRouteBitcoinNativeTransactionOperation(
                  destination: destination,
                  source: sourceAddress,
                  network: sourceNetwork.cast(),
                  memo: memo,
                  amount: quote.amount)
            ]);
      case SwapChainType.cosmos:
        final CosmosBaseAddress destination =
            SwapUtils.toNetworkAddress(sourceNetwork, route.inboundAddress);
        final CosmosBaseAddress source =
            SwapUtils.toNetworkAddress(sourceNetwork, params.sourceAddress);
        return SwapRouteCosmosTransactionBuilder(
            route: this,
            params: params,
            operations: [
              SwapRouteCosmosNativeTransactionOperation(
                  amount: quote.amount,
                  source: source,
                  destination: destination,
                  network: sourceNetwork.cast(),
                  memo: memo)
            ]);
      default:
        throw DartOnChainSwapPluginException(
            "Unsuported swap network. ${quote.sourceAsset.network.name}");
    }
  }
}
