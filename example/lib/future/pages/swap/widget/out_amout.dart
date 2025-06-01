import 'package:onchain_swap_example/swap/swap.dart';
import 'package:on_chain_swap/onchain_swap.dart';
import 'package:onchain_swap_example/app/types/types.dart';
import 'package:onchain_swap_example/future/state_managment/state_managment.dart';
import 'package:onchain_swap_example/future/widgets/custom_widgets.dart';
import 'package:flutter/material.dart';

class SwapAmountOutView extends StatelessWidget {
  final BaseSwapAsset? destinationAsset;
  final DynamicVoid onChangeAsset;
  final APPSwapRoutes? route;
  const SwapAmountOutView(
      {super.key,
      required this.destinationAsset,
      required this.onChangeAsset,
      required this.route});

  @override
  Widget build(BuildContext context) {
    final controller = context.mainController;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Shimmer(
            count: 1,
            enable: !controller.status.isPending,
            onActive: (enable, context) {
              return ContainerWithBorder(
                onRemove: onChangeAsset,
                onRemoveWidget:
                    Icon(Icons.edit, color: context.onPrimaryContainer),
                child: Row(
                  children: [
                    SizedBox(
                      width: 70,
                      height: 70,
                      child: Material(
                        elevation: 5,
                        color: context.colors.primaryContainer,
                        shape: CircleBorder(),
                        child: Stack(
                          children: [
                            CircleTokenImageView(destinationAsset, radius: 35),
                            Align(
                              alignment: Alignment.topRight,
                              child: CircleNetworkImageView(
                                  destinationAsset?.network,
                                  radius: 10),
                            )
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: IgnorePointer(
                        child: Padding(
                          padding: WidgetConstant.paddingHorizontal10,
                          child: LiveWidget(() {
                            final currentRoute = route?.route;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                APPAnimated(
                                    isActive: true,
                                    onActive: (context) => ConditionalWidget(
                                          key: ValueKey(route?.index),
                                          enable: destinationAsset != null,
                                          onDeactive: (context) => Text(
                                            "0.0",
                                            style: context.textTheme.titleLarge
                                                ?.copyWith(
                                                    color: context.colors
                                                        .onPrimaryContainer,
                                                    fontSize: 30,
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                          onActive: (context) => CoinPriceView(
                                            token: destinationAsset!,
                                            amount: currentRoute
                                                    ?.route.expectedAmount ??
                                                SwapAmount.zero,
                                            symbolColor: context
                                                .colors.onPrimaryContainer,
                                            style: context.textTheme.titleLarge
                                                ?.copyWith(
                                                    color: context.colors
                                                        .onPrimaryContainer,
                                                    fontSize: 30,
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                        ),
                                    onDeactive: (context) =>
                                        WidgetConstant.sizedBox),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
      ],
    );
  }
}
