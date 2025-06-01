import 'package:onchain_swap_example/app/constants/constants.dart';
import 'package:onchain_swap_example/future/pages/swap/widget/address.dart';
import 'package:onchain_swap_example/future/pages/swap/widget/amount_in.dart';
import 'package:onchain_swap_example/future/pages/swap/widget/out_amout.dart';
import 'package:onchain_swap_example/future/pages/swap/widget/config.dart';
import 'package:onchain_swap_example/future/pages/swap/widget/select_asset.dart';
import 'package:onchain_swap_example/app/constants/state.dart';
import 'package:onchain_swap_example/future/pages/swap/controller/swap.dart';
import 'package:onchain_swap_example/future/router/router.dart';
import 'package:onchain_swap_example/future/state_managment/state_managment.dart';
import 'package:onchain_swap_example/future/pages/wallet_scanner/state/wallet_scanner.dart';
import 'package:onchain_swap_example/future/widgets/custom_widgets.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MrtViewBuilder(
        removable: false,
        controller: () => context.mainController,
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              title: Text(APPConst.name),
              actions: [
                IconButton(
                    onPressed: () {
                      context.to(PageRouter.settings);
                    },
                    icon: Icon(Icons.settings)),
                ConditionalWidget(
                    onActive: (context) {
                      return TextButton.icon(
                        onPressed: () {
                          context.openDialogPage(
                            label: '',
                            child: (context) => WalletScannerView(
                                tracker: controller.sourceWalletTracker!),
                          );
                        },
                        label: Text("wallets".tr),
                        icon: Icon(Icons.wallet),
                      );
                    },
                    enable: controller.sourceWalletTracker != null)
              ],
            ),
            body: PageProgress(
                key: controller.progressKey,
                // initialStatus: StreamWidgetStatus.progress,
                child: (context) {
                  return IgnorePointer(
                      ignoring: controller.page == SwapPage.review,
                      child: _SwapView(controller));
                }),
          );
        },
        repositoryId: StateConst.main);
  }
}

class _SwapView extends StatelessWidget {
  final SwapStateController controller;
  const _SwapView(this.controller) : super();

  @override
  Widget build(BuildContext context) {
    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      key: controller.formKey,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Material(
                    shape: CircleBorder(),
                    elevation: 10,
                    child: CircleTokenImageView(
                      controller.sourceAsset,
                      radius: 120,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 80),
                    child: Opacity(
                      opacity: 0.9,
                      child: Material(
                        shape: CircleBorder(),
                        elevation: 10,
                        child: CircleTokenImageView(
                          controller.destinationAsset,
                          radius: 120,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            color: context.colors.surface.wOpacity(0.3),
            child: CustomScrollView(
              slivers: [
                WidgetConstant.sliverPaddingVertial40,
                SliverConstraintsBoxView(
                  padding: WidgetConstant.paddingHorizontal10,
                  sliver: SliverMainAxisGroup(slivers: [
                    SliverToBoxAdapter(
                      child: Row(
                        children: [
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SetupSwapAmoutView(
                                  sourceAsset: controller.sourceAsset,
                                  onChangeAsset: () {
                                    context.openDialogPage(
                                        label: '',
                                        child: (context) =>
                                            SwapSelectAssetView(true));
                                  }),
                              SwapAmountOutView(
                                destinationAsset: controller.destinationAsset,
                                route: controller.currentRoute,
                                onChangeAsset: () {
                                  context.openDialogPage(
                                      label: '',
                                      child: (context) =>
                                          SwapSelectAssetView(false));
                                },
                              ),
                            ],
                          ))
                        ],
                      ),
                    ),
                    SliverToBoxAdapter(
                        child: Column(
                      children:
                          List.generate(controller.errors.length, (index) {
                        final error = controller.errors[index];
                        return ContainerWithBorder(
                          backgroundColor: context.colors.errorContainer,
                          child: Row(
                            children: [
                              if (error.provider != null) ...[
                                CircleServiceProviderImageView(error.provider!,
                                    radius: APPConst.circleRadius25),
                                WidgetConstant.width8
                              ],
                              Expanded(
                                  child: Text(error.error.tr,
                                      style: context.textTheme.bodyMedium
                                          ?.copyWith(
                                              color: context
                                                  .colors.onErrorContainer)))
                            ],
                          ),
                        );
                      }),
                    )),
                    ConditionalWidget(
                        enable: controller.hasRoute,
                        onActive: (context) => SliverToBoxAdapter(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RouteConfigView(
                                      routes: controller.currentRoute!),
                                  WidgetConstant.height20,
                                  SwapAddressesView(controller: controller)
                                ],
                              ),
                            ),
                        onDeactive: (context) => WidgetConstant.sliverSizedBox),
                  ]),
                ),
                WidgetConstant.sliverPaddingVertial40,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
