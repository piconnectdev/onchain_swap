import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:onchain_swap_example/app/constants/constants.dart';
import 'package:onchain_swap_example/future/pages/swap/controller/controller.dart';
import 'package:onchain_swap_example/future/state_managment/state_managment.dart';
import 'package:onchain_swap_example/future/widgets/custom_widgets.dart';
import 'package:flutter/material.dart';
import 'package:on_chain_swap/on_chain_swap.dart';

class SelectSwapProvidersView extends StatefulWidget {
  const SelectSwapProvidersView({super.key});

  @override
  State<SelectSwapProvidersView> createState() =>
      _SelectSwapProvidersViewState();
}

class _SelectSwapProvidersViewState extends State<SelectSwapProvidersView>
    with SafeState<SelectSwapProvidersView> {
  late HomeStateController controller;
  ChainType chainType = ChainType.testnet;
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
    updateSettings();
    updateState();
  }

  void updateSettings() {
    final providers = activeProviders.clone();
    providers.sort((a, b) =>
        supportProviders.indexOf(a).compareTo(supportProviders.indexOf(b)));
    controller.setAppSetting(controller.appSetting
        .copyWith(chainType: chainType, swapProviders: providers));
  }

  void toggleChainType() {
    activeProviders.clear();
    switch (chainType) {
      case ChainType.testnet:
        chainType = ChainType.mainnet;
        supportProviders = SwapConstants.supportProviders;

        break;
      case ChainType.mainnet:
        chainType = ChainType.testnet;
        supportProviders = SwapConstants.testnetProviders;
        break;
    }
    activeProviders.addAll(supportProviders);
    updateSettings();
    updateState();
  }

  @override
  void onInitOnce() {
    controller = context.mainController;
    chainType = controller.appSetting.chainType;
    switch (chainType) {
      case ChainType.mainnet:
        supportProviders = SwapConstants.supportProviders;
        break;
      case ChainType.testnet:
        supportProviders = SwapConstants.testnetProviders;
        break;
    }
    activeProviders = controller.appSetting.swapProviders.clone();
    super.onInitOnce();
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(children: [
        AppSwitchListTile(
          value: chainType.isMainnet,
          title: Text("mainnet".tr),
          onChanged: (p0) => toggleChainType(),
        ),
        Divider(),
        APPAnimatedSize(
          isActive: true,
          onDeactive: (context) => WidgetConstant.sizedBox,
          onActive: (context) => ListView(
            key: ValueKey(supportProviders.length),
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
          ),
        ),
        WidgetConstant.height40,
      ]),
    );
  }
}
