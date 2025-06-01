import 'package:on_chain_swap/onchain_swap.dart';
import 'package:flutter/material.dart';
import 'assets_image.dart';
import 'tooltip/widgets/tooltip.dart';
import 'widget_constant.dart';
import 'package:onchain_swap_example/future/state_managment/state_managment.dart';

class PriceTooltipWidget extends StatelessWidget {
  const PriceTooltipWidget(
      {super.key,
      required this.price,
      required this.symbol,
      required this.currencyName});
  final String price;
  final String symbol;
  final String currencyName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
        constraints: const BoxConstraints(maxWidth: 300),
        child: RichText(
            text: TextSpan(
                style: theme.textTheme.titleLarge
                    ?.copyWith(color: theme.colorScheme.onTertiaryContainer),
                children: [
              TextSpan(text: price.to3Digits),
              const TextSpan(text: " "),
              TextSpan(
                  text: symbol,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.onTertiaryContainer)),
              TextSpan(
                  text: " ($currencyName) ",
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: theme.colorScheme.onTertiaryContainer)),
            ])));
  }
}

class CoinPriceView extends StatelessWidget {
  const CoinPriceView({
    super.key,
    required this.token,
    required this.amount,
    this.style,
    this.symbolColor,
    this.disableTooltip = false,
    this.showTokenImage = false,
    this.enableMarketPrice = true,
  });

  final BaseSwapAsset token;
  final SwapAmount amount;
  final TextStyle? style;
  final Color? symbolColor;
  final bool disableTooltip;
  final bool showTokenImage;
  final bool enableMarketPrice;
  @override
  Widget build(BuildContext context) {
    final BaseSwapAsset coin = token;
    final wallet = context.mainController;

    return LiveWidget(() {
      final price = amount.amountString;
      final tokenPrice = wallet.getTokenPrice(price, token);
      return ToolTipView(
        tooltipWidget: disableTooltip
            ? null
            : (c) => PriceTooltipWidget(
                currencyName: coin.fullName ?? coin.symbol,
                price: amount.amountString,
                symbol: coin.symbol),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showTokenImage) ...[
                    CircleTokenImageView(token, radius: 10),
                    WidgetConstant.width8,
                  ],
                  Flexible(
                    child: RichText(
                        textDirection: TextDirection.ltr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                            style: style ?? context.textTheme.labelLarge,
                            children: [
                              TextSpan(text: amount.amountString.to3Digits),
                              const TextSpan(text: " "),
                            ])),
                  ),
                  Text(
                    coin.symbol,
                    style: context.textTheme.labelSmall?.copyWith(
                        color: symbolColor ?? context.colors.primary),
                  ),
                ],
              ),
              if (enableMarketPrice)
                CoinStringPriceView(
                  balance: tokenPrice,
                  symbolColor: symbolColor,
                  disableTooltip: false,
                  style: null,
                ),
            ],
          ),
        ),
      );
    });
  }
}

class CoinStringPriceView extends StatelessWidget {
  const CoinStringPriceView({
    super.key,
    required this.balance,
    this.symbolColor,
    this.style,
    this.disableTooltip = false,
  });
  final SwapAmount? balance;
  final TextStyle? style;
  final Color? symbolColor;
  final bool disableTooltip;
  @override
  Widget build(BuildContext context) {
    final bl = balance;
    if (bl == null) return WidgetConstant.sizedBox;
    final price = bl.amountString;
    final token = context.mainController.currencyToken;
    return ToolTipView(
      tooltipWidget: disableTooltip
          ? null
          : (c) => PriceTooltipWidget(
              currencyName: token.name, price: price, symbol: token.name),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: RichText(
                      textDirection: TextDirection.ltr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                          style: style ??
                              context.textTheme.labelSmall
                                  ?.copyWith(color: symbolColor),
                          children: [
                            TextSpan(text: price.to3Digits),
                            const TextSpan(text: " "),
                          ])),
                ),
                Text(
                  token.name,
                  style: context.textTheme.labelSmall
                      ?.copyWith(color: symbolColor ?? context.colors.primary),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
