import 'package:onchain_swap_example/app/constants/constants.dart';
import 'package:onchain_swap_example/swap/swap.dart';
import 'package:onchain_swap_example/future/state_managment/state_managment.dart';
import 'package:onchain_swap_example/future/widgets/custom_widgets.dart';
import 'package:flutter/material.dart';
import 'package:onchain_swap/onchain_swap.dart';

class RouteConfigView extends StatelessWidget {
  final APPSwapRoutes routes;

  const RouteConfigView({required this.routes, super.key});

  @override
  Widget build(BuildContext context) {
    return LiveWidget(() {
      final SwapRouteWithBps route = routes.route;
      return ContainerWithBorder(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(children: [
              SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                      maxWidth: APPConst.naviationRailWidth),
                  child: IntrinsicHeight(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: NavigationRail(
                          minWidth: APPConst.naviationRailWidth,
                          backgroundColor: context.colors.primaryContainer,
                          useIndicator: true,
                          onDestinationSelected: (v) {
                            routes.onChangeRoute(v.toInt());
                          },
                          labelType: NavigationRailLabelType.all,
                          indicatorShape: CircleBorder(),
                          destinations:
                              List.generate(routes.routes.length, (index) {
                            final network = routes.routes[index];
                            return NavigationRailDestination(
                                icon: Badge(
                                  // offset: Offset(-5, 0),
                                  alignment: Alignment(-3, -1),

                                  isLabelVisible: network.bps != null,
                                  textStyle: context.textTheme.labelSmall,
                                  label: ConditionalWidget(
                                      enable:
                                          network.bps?.bpsPercentage != null,
                                      onActive: (context) => Text(
                                            network.bps!.bpsPercentage,
                                            style: context.textTheme.labelSmall
                                                ?.copyWith(
                                                    color:
                                                        context.colors.onError),
                                          )),
                                  child: AnimatedContainer(
                                      padding: WidgetConstant.padding5,
                                      duration: APPConst.animationDuraion,
                                      decoration: BoxDecoration(
                                          color: index == routes.index
                                              ? context.colors.inversePrimary
                                              : context.colors.transparent,
                                          shape: BoxShape.circle),
                                      child: CircleServiceProviderImageView(
                                          network.provider,
                                          radius: 15)),
                                ),
                                label: WidgetConstant.sizedBox,
                                disabled: false);
                          }),
                          selectedIndex: routes.index),
                    ),
                  ),
                ),
              ),
            ]),
            Expanded(
                child: APPAnimated(
                    isActive: true,
                    onActive: (context) => Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RouteInfoView(route: route),
                            ThorSwapConfigView(routes: routes)
                          ],
                        ),
                    onDeactive: (context) => WidgetConstant.sizedBox))
          ],
        ),
      );
    });
  }
}

class RouteInfoView extends StatelessWidget {
  const RouteInfoView({required this.route, super.key});
  final SwapRouteWithBps route;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ContainerWithBorder(
                backgroundColor: context.onPrimaryContainer,
                child: Row(
                  children: [
                    CircleServiceProviderImageView(route.provider, radius: 12),
                    WidgetConstant.width8,
                    Expanded(
                        child: OneLineTextWidget(route.provider.name,
                            style: context.primaryTextTheme.bodyMedium))
                  ],
                ),
              ),
            ),
            Expanded(
              child: TappedTooltipView(
                tooltipWidget: ToolTipView(
                    message: "lowest_expected_amount".tr,
                    child: ContainerWithBorder(
                      backgroundColor: context.onPrimaryContainer,
                      onRemove: () {},
                      enableTap: false,
                      onRemoveWidget: Text(
                          "${route.route.worstPercentage.toStringAsFixed(1)}%",
                          style: context.primaryTextTheme.labelLarge
                              ?.copyWith(color: context.colors.errorContainer)),
                      child: Row(
                        children: [
                          Icon(Icons.arrow_downward,
                              color: context.colors.errorContainer),
                          WidgetConstant.width8,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CoinPriceView(
                                    token: route.route.quote.destinationAsset,
                                    amount: route.route.worstCaseAmount,
                                    showTokenImage: true,
                                    symbolColor: context.primaryContainer,
                                    style:
                                        context.primaryTextTheme.titleMedium),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
              ),
            )
          ],
        ),
        Row(
          children: [
            Expanded(
                child: ConditionalWidget(
                    enable: route.bps != null,
                    onDeactive: (context) => ContainerWithBorder(
                          backgroundColor: context.onPrimaryContainer,
                          child: Row(
                            children: [
                              Icon(Icons.show_chart,
                                  color: context.primaryContainer),
                              WidgetConstant.width8,
                              Expanded(
                                  child: Text("market_price_unavailable".tr,
                                      style:
                                          context.primaryTextTheme.bodyMedium)),
                            ],
                          ),
                        ),
                    onActive: (context) {
                      final bps = route.bps!;
                      return ContainerWithBorder(
                        backgroundColor: context.onPrimaryContainer,
                        enableTap: false,
                        onRemoveWidget: Text(
                          bps.bpsPercentage,
                          style: context.primaryTextTheme.labelLarge?.copyWith(
                              color: bps.minus
                                  ? context.colors.errorContainer
                                  : context.colors.primaryContainer),
                        ),
                        onRemove: () {},
                        child: Row(
                          children: [
                            Icon(Icons.show_chart,
                                color: bps.minus
                                    ? context.colors.errorContainer
                                    : context.primaryContainer),
                            WidgetConstant.width8,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CoinStringPriceView(
                                    balance: bps.amount,
                                    style: context.primaryTextTheme.titleMedium,
                                    symbolColor: context.primaryContainer,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    })),
            Expanded(
              child: ContainerWithBorder(
                backgroundColor: context.onPrimaryContainer,
                onRemove: () {
                  context.openSliverDialog(
                    label: 'fees'.tr,
                    widget: (context) => RouteFeesView(
                      fees: route.route.fees,
                      initiallyExpanded: true,
                    ),
                  );
                },
                onRemoveIcon:
                    Icon(Icons.info, color: context.colors.primaryContainer),
                child: Row(
                  children: [
                    Icon(Icons.local_gas_station,
                        color: context.colors.primaryContainer),
                    WidgetConstant.width8,
                    Expanded(
                        child: ConditionalWidget(
                      enable: route.totalFee != null,
                      onDeactive: (context) => Text("tap_to_review_fees".tr,
                          style: context.primaryTextTheme.bodyMedium),
                      onActive: (context) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CoinStringPriceView(
                              balance: route.totalFee!,
                              symbolColor: context.primaryContainer,
                              style: context.primaryTextTheme.titleMedium)
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            )
          ],
        ),
        Row(
          children: [
            Expanded(
              child: TappedTooltipView(
                  tooltipWidget: ToolTipView(
                      message: "expected_swap_duration".tr,
                      child: ContainerWithBorder(
                        backgroundColor: context.onPrimaryContainer,
                        child: Row(
                          children: [
                            Icon(Icons.timer,
                                color: context.colors.primaryContainer),
                            WidgetConstant.width8,
                            Expanded(
                                child: Text(
                                    "n_minutes".tr.replaceOne(
                                        route.route.estimateTime.toString()),
                                    style: context.primaryTextTheme.bodyMedium))
                          ],
                        ),
                      ))),
            ),
            Expanded(
              child: ContainerWithBorder(
                backgroundColor: context.onPrimaryContainer,
                child: Row(
                  children: [
                    Icon(Icons.timer_off,
                        color: context.colors.primaryContainer),
                    WidgetConstant.width8,
                    Expanded(
                        child: ConditionalWidget(
                            enable: route.route.expireTime != null,
                            onActive: (context) => Text(
                                route.route.expireTime!.toDateAndTime(),
                                style: context.primaryTextTheme.bodyMedium)))
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ThorSwapConfigView extends StatelessWidget {
  final APPSwapRoutes routes;
  const ThorSwapConfigView({required this.routes, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ConditionalWidget(
          enable: routes.supportTolerance,
          onActive: (context) => ContainerWithBorder(
                backgroundColor: context.onPrimaryContainer,
                child: Row(
                  children: [
                    Text("tolerance".tr,
                        style: context.primaryTextTheme.bodyMedium),
                    Expanded(
                      child: Slider(
                        min: 0.0,
                        max: routes.maxTolerance,
                        divisions: (routes.maxTolerance * 4).toInt(),
                        value: routes.tolerance,
                        onChanged: routes.updateTolerance,
                        label: '${routes.tolerance.toStringAsFixed(1)}%',
                      ),
                    )
                  ],
                ),
              ))
    ]);
  }
}

class RouteFeesView extends StatelessWidget {
  final List<SwapFee> fees;
  final bool initiallyExpanded;
  const RouteFeesView({
    required this.fees,
    super.key,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return APPAnimatedSwitcher<bool>(enable: fees.isNotEmpty, widgets: {
      false: (context) => WidgetConstant.sizedBox,
      true: (context) =>
          _RouteFeesView(fees: fees, initiallyExpanded: initiallyExpanded)
    });
  }
}

class _RouteFeesView extends StatelessWidget {
  final List<SwapFee> fees;
  final bool initiallyExpanded;
  const _RouteFeesView({required this.fees, this.initiallyExpanded = false});

  @override
  Widget build(BuildContext context) {
    return APPExpansionListTile(
      initiallyExpanded: initiallyExpanded,
      title: Text("fees".tr, style: context.onPrimaryTextTheme.bodyMedium),
      radius: WidgetConstant.border8,
      children: [
        ListView.separated(
            itemBuilder: (context, index) => _FeeInfo(fee: fees[index]),
            separatorBuilder: (context, index) => Divider(),
            itemCount: fees.length,
            shrinkWrap: true,
            physics: WidgetConstant.noScrollPhysics)
      ],
    );
  }
}

class _FeeInfo extends StatelessWidget {
  final SwapFee fee;
  const _FeeInfo({required this.fee});

  @override
  Widget build(BuildContext context) {
    return ContainerWithBorder(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("provider".tr, style: context.onPrimaryTextTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
          backgroundColor: context.onPrimaryContainer,
          child: Text(fee.type.camelCase,
              style: context.primaryTextTheme.bodyMedium),
        ),
        WidgetConstant.height20,
        Text("amount".tr, style: context.onPrimaryTextTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
            backgroundColor: context.onPrimaryContainer,
            child: ConditionalWidget(
                onActive: (context) => CoinPriceView(
                    token: fee.token!,
                    amount: fee.amount,
                    showTokenImage: true,
                    symbolColor: context.primaryContainer,
                    style: context.primaryTextTheme.titleMedium))),
      ]),
    );
  }
}
