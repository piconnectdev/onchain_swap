import 'package:onchain_swap/src/providers/skip_go/models/types/types.dart';
import 'package:onchain_swap/src/swap/types/types.dart';

import 'chains.dart';

class SkipGoQuoteSwapParams extends QuoteSwapParams<SkipGoSwapAsset> {
  final bool allowMultiTx;
  final bool goFast;
  final bool smartRelay;
  final bool unsafe;
  SkipGoQuoteSwapParams(
      {required super.sourceAsset,
      required super.destinationAsset,
      required super.amount,
      super.sourceAddress,
      super.destinationAddress,
      this.goFast = true,
      this.smartRelay = true,
      this.allowMultiTx = false,
      this.unsafe = false});
}

class SkipGoSwapRoute extends SwapRoute<SkipGoQuoteSwapParams,
    SwapRouteGeneralTransactionBuilderParam> {
  final SkipGoApiRoute route;

  SkipGoSwapRoute(
      {required super.expireTime,
      required super.expectedAmount,
      required super.quote,
      required this.route,
      required super.estimateTime,
      required super.provider,
      required super.fees,
      required super.tolerance,
      required super.worstCaseAmount});

  @override
  SwapRoute<QuoteSwapParams<BaseSwapAsset>,
          SwapRouteGeneralTransactionBuilderParam>
      updateTolerance(double tolerance) {
    throw UnimplementedError();
  }
}
