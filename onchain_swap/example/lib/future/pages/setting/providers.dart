import 'package:example/app/constants/constants.dart';
import 'package:example/future/state_managment/state_managment.dart';
import 'package:example/future/widgets/custom_widgets.dart';
import 'package:flutter/material.dart';
import 'package:onchain_swap/onchain_swap.dart';

class SelectSwapProvidersView extends StatefulWidget {
  final List<SwapServiceProvider> activeProviders;
  const SelectSwapProvidersView(this.activeProviders, {super.key});

  @override
  State<SelectSwapProvidersView> createState() =>
      _SelectSwapProvidersViewState();
}

class _SelectSwapProvidersViewState extends State<SelectSwapProvidersView>
    with SafeState<SelectSwapProvidersView> {
  List<SwapServiceProvider> activeProviders = [];
  List<SwapServiceProvider> supportProviders = [];

  void addOrRemoveProvider(SwapServiceProvider provider) {
    if (activeProviders.length == 1 && activeProviders.contains(provider)) {
      context.showAlert("at_least_one_provider_must_enabled".tr);
      return;
    }
    if (!activeProviders.remove(provider)) {
      activeProviders.add(provider);
    }
    updateState();
  }

  @override
  void initState() {
    super.initState();
    supportProviders = SwapConstants.supportProviders;
    activeProviders = widget.activeProviders;
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(children: [
        ListView(
          shrinkWrap: true,
          physics: WidgetConstant.noScrollPhysics,
          children: List.generate(supportProviders.length, (index) {
            final provider = supportProviders[index];
            return ContainerWithBorder(
              onRemove: () {
                addOrRemoveProvider(provider);
              },
              onRemoveIcon: APPCheckBox(
                value: activeProviders.contains(provider),
                backgroundColor: context.onPrimaryContainer,
                color: context.primaryContainer,
              ),
              child: Row(
                children: [
                  CircleServiceProviderImageView(provider,
                      radius: APPConst.circleRadius25),
                  WidgetConstant.width8,
                  Expanded(
                      child: OneLineTextWidget(provider.name,
                          style: context.onPrimaryTextTheme.bodyMedium))
                ],
              ),
            );
          }),
        )
      ]),
    );
  }
}
