import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:onchain_swap/src/swap/services/thor/thor/route.dart'
    show ThorSwapRoute;
import 'package:onchain_swap/src/swap/types/types.dart';
import 'package:onchain_swap/src/swap/utils/utils.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';

class ThorSwapUtils {
  static String abbreviateFuzzy(String asset, {bool short = true}) {
    final parts = asset.split('.');
    if (parts.length != 2) return asset;
    final chain = parts[0];
    final symbolParts = parts[1].split('-');
    final ticker = symbolParts[0];
    final address = symbolParts.length > 1 ? symbolParts[1] : '';
    if (address.isEmpty || short) {
      return "$chain.$ticker"; // e.g. "RUNE"
    }
    return '$chain.$ticker-${address.substring(address.length - 3)}';
  }

  static double ceilBpsToDouble(int bps) {
    return (((bps + 99) ~/ 100) * 100) / 100;
  }

  static String buildMemo(ThorSwapRoute route, String destination) {
    final interval = route.interval;
    String assetIdentifier = route.quote.destinationAsset.providerIdentifier;
    if (route.quote.destinationAsset.isContract) {
      assetIdentifier = abbreviateFuzzy(assetIdentifier, short: true);
    }
    if (route.tolerance == 0 && interval == null) {
      return "=:$assetIdentifier:$destination";
    }

    /// 58688998000
    /// 57298026550
    BigInt worstAmount = BigInt.zero;
    if (route.tolerance != 0) {
      worstAmount = calculateWorstCaseAmount(
              expectedAmount: route.route.expectedAmountOut,
              tolranceBps: route.tolerance)
          .amount;
    }

    if (interval == null) {
      return "=:$assetIdentifier:$destination:$worstAmount";
    }
    return "=:$assetIdentifier:$destination:$worstAmount/$interval/0";
  }

  static SwapAmount calculateWorstCaseAmount(
      {required BigInt expectedAmount, required double tolranceBps}) {
    final tolerance = (tolranceBps * 100).ceil();
    final toleranceMultiplier =
        BigRational.from(10000 - tolerance) / BigRational.from(10000);
    final expected = BigRational(expectedAmount);
    final worstCaseDecimal = expected * toleranceMultiplier;
    return SwapAmount.fromBigInt(worstCaseDecimal.toBigInt(), 8);
  }

  static List<SwapFee> buildQuoteFee(
      {required ThoreNodeQouteSwapFeeResponse fees, BaseSwapAsset? asset}) {
    if (asset == null) return [];
    final liquidity = BigintUtils.tryParse(fees.liquidity);
    final outbound = BigintUtils.tryParse(fees.outbound);
    final affiliate = BigintUtils.tryParse(fees.affiliate);
    return [
      if (liquidity != null && liquidity > BigInt.zero)
        SwapFee(
            token: asset,
            amount: toAmountFromBigInt(asset: asset, amount: liquidity),
            type: SwapFeeType.liquidity.name,
            asset: asset.symbol),
      if (outbound != null && outbound > BigInt.zero)
        SwapFee(
            token: asset,
            amount: toAmountFromBigInt(asset: asset, amount: outbound),
            type: SwapFeeType.outbound.name,
            asset: asset.symbol),
      if (affiliate != null && affiliate > BigInt.zero)
        SwapFee(
            token: asset,
            amount: toAmountFromBigInt(asset: asset, amount: affiliate),
            type: SwapFeeType.affiliate.name,
            asset: asset.symbol),
    ];
  }

  static SwapAmount toAmountFromInput(
      {required BaseSwapAsset asset, required String amount}) {
    if (asset.decimal == 8) {
      return SwapAmount.fromString(amount, 8);
    }
    final decodePrice =
        BigRational(SwapUtils.decodePrice(amount, asset.decimal));
    final decimals = 8 - asset.decimal;
    if (decimals.isNegative) {
      final amountBig =
          (decodePrice / BigRational(BigInt.from(10).pow(decimals.abs())))
              .toBigInt();
      return SwapAmount.fromBigInt(amountBig, 8);
    }
    final amountBig =
        (decodePrice * BigRational(BigInt.from(10).pow(decimals))).toBigInt();
    return SwapAmount.fromBigInt(amountBig, 8);
  }

  static SwapAmount toAmountFromBigInt(
      {required BaseSwapAsset asset, required BigInt amount}) {
    return SwapAmount.fromBigInt(amount, 8);
  }
}
