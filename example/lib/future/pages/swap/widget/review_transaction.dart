import 'package:onchain_swap_example/api/services/types/types.dart';
import 'package:onchain_swap_example/future/pages/swap/controller/transaction.dart';
import 'package:onchain_swap_example/future/pages/swap/widget/import_provider.dart';
import 'package:onchain_swap_example/future/pages/swap/widget/config.dart';
import 'package:onchain_swap_example/swap/swap.dart';
import 'package:on_chain_swap/on_chain_swap.dart';
import 'package:onchain_swap_example/future/state_managment/state_managment.dart';
import 'package:onchain_swap_example/future/widgets/custom_widgets.dart';
import 'package:flutter/material.dart';

class TransactionReviewView extends StatelessWidget {
  final SwapRouteTransactionBuilder transaction;
  final SwapRouteWithBps route;
  const TransactionReviewView(
      {required this.transaction, required this.route, super.key});

  @override
  Widget build(BuildContext context) {
    return MrtViewBuilder<SwapTransactionStateController>(
      controller: () => SwapTransactionStateController(
          transaction: transaction, route: route),
      builder: (controller) {
        return PopScope(
          canPop: controller.allowPop,
          onPopInvokedWithResult: (didPop, result) async {
            final close = await controller.onPop(() async {
              return context.openSliverDialog<bool>(
                label: 'close_page'.tr,
                widget: (context) => DialogTextView(
                    text: "close_swap_page_desc".tr,
                    buttonWidget: DialogDoubleButtonView()),
              );
            });
            if (close == true && context.mounted) context.popToHome();
          },
          child: Scaffold(
            appBar: AppBar(title: Text("transaction".tr)),
            body: PageProgress(
              key: controller.progressKey,
              child: (context) => CustomScrollView(
                slivers: [
                  SliverConstraintsBoxView(
                      padding: WidgetConstant.paddingHorizontal20,
                      sliver: SliverMainAxisGroup(slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Stack(
                                    children: [
                                      Material(
                                        shape: CircleBorder(),
                                        elevation: 10,
                                        child: CircleTokenImageView(
                                          controller.transaction.route.quote
                                              .sourceAsset,
                                          radius: 60,
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
                                              controller.transaction.route.quote
                                                  .destinationAsset,
                                              radius: 60,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              WidgetConstant.height20,
                              ContainerWithBorder(
                                child: Column(children: [
                                  Row(
                                    children: [
                                      Expanded(
                                          child: ContainerWithBorder(
                                        backgroundColor:
                                            context.onPrimaryContainer,
                                        child: CoinPriceView(
                                          showTokenImage: true,
                                          token: controller.transaction.route
                                              .quote.sourceAsset,
                                          amount: controller
                                              .transaction.route.quote.amount,
                                          style: context
                                              .primaryTextTheme.titleMedium,
                                          symbolColor: context.primaryContainer,
                                        ),
                                      )),
                                      Icon(Icons.forward, size: 45),
                                      Expanded(
                                          child: ContainerWithBorder(
                                        backgroundColor:
                                            context.onPrimaryContainer,
                                        child: CoinPriceView(
                                          showTokenImage: true,
                                          token: controller.transaction.route
                                              .quote.destinationAsset,
                                          amount: controller
                                              .transaction.route.expectedAmount,
                                          style: context
                                              .primaryTextTheme.titleMedium,
                                          symbolColor: context.primaryContainer,
                                        ),
                                      ))
                                    ],
                                  ),
                                  RouteInfoView(route: controller.route),
                                  ContainerWithBorder(
                                    backgroundColor: context.onPrimaryContainer,
                                    child: CopyableTextWidget(
                                        text: transaction
                                            .params.destinationAddress,
                                        color: context.primaryContainer),
                                  ),
                                ]),
                              ),
                              ConditionalWidget(
                                  enable: controller
                                          .transaction.route.provider.service ==
                                      SwapServiceType.chainFlip,
                                  onActive: (context) => Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          WidgetConstant.height20,
                                          Text("channel".tr,
                                              style: context
                                                  .textTheme.titleMedium),
                                          WidgetConstant.height8,
                                          _CfChannelInformation(
                                              channel: controller
                                                  .transaction.params
                                                  .cast())
                                        ],
                                      )),
                              WidgetConstant.height20,
                              WarningTextContainer(
                                  message: "operation_manually_desc".tr,
                                  enableTap: false),
                              WidgetConstant.height20,
                              Text("operations".tr,
                                  style: context.textTheme.titleMedium),
                              WidgetConstant.height8,
                            ],
                          ),
                        ),
                        SliverPadding(
                          padding: WidgetConstant.padding5,
                          sliver: SliverList.separated(
                            itemCount: controller.transaction.operations.length,
                            separatorBuilder: (context, index) =>
                                WidgetConstant.height8,
                            itemBuilder: (context, index) {
                              final operation =
                                  controller.transaction.operations[index];
                              if (operation
                                  is SwapRouteTransactionTransferDetails) {
                                return _TransactionNativeTransferOperationView(
                                    operation: operation,
                                    route: controller.transaction.route);
                              } else if (operation
                                  is SwapRouteTransactionContractDetails) {
                                return _TransactionNativeContractOperationView(
                                    operation: operation,
                                    route: controller.transaction.route);
                              }
                              return WidgetConstant.sizedBox;
                            },
                          ),
                        ),
                        SliverToBoxAdapter(
                            child: ErrorTextContainer(
                                error: controller.latestError)),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: WidgetConstant.paddingVertical40,
                            child: Shimmer(
                              count: 1,
                              enable: !controller.inProgress,
                              onActive: (enable, context) =>
                                  FixedElevatedButton(
                                activePress: controller.hasWallet,
                                height: 70,
                                width: context.mediaQuery.size.width,
                                onPressed: () {
                                  controller.signTransaction(
                                      (network, service) async {
                                    ServiceInfo? service;
                                    await context
                                        .openSliverBottomSheet<ServiceInfo>(
                                      'service_provider'.tr,
                                      bodyBuilder: (c) =>
                                          HTTPServiceProviderFields(
                                        network: network,
                                        controller: c,
                                        onAddNewProvider: (s) {
                                          service = s;
                                          context.pop();
                                        },
                                        title: Column(
                                          children: [
                                            ErrorTextContainer(
                                                enableTap: false,
                                                error:
                                                    "missing_provider_desc".tr),
                                            WidgetConstant.height20,
                                          ],
                                        ),
                                      ),
                                    );
                                    return service;
                                  });
                                },
                                child: ConditionalWidget(
                                    enable: controller.hasWallet,
                                    onDeactive: (context) =>
                                        Text("no_wallet_detected".tr),
                                    onActive: (context) => APPAnimatedSwitcher<
                                            TransactionOperationStep?>(
                                          enable: controller.step,
                                          widgets: {
                                            null: (context) => Text(
                                                "sign_and_send_transaction".tr),
                                            TransactionOperationStep.client:
                                                (context) => Text(
                                                    "connecting_to_network".tr),
                                            TransactionOperationStep.signing:
                                                (context) => Text(
                                                    "signing_transaction".tr),
                                            TransactionOperationStep.broadcast:
                                                (context) => Text(
                                                    "broadcasting_transaction"
                                                        .tr),
                                            TransactionOperationStep.complete:
                                                (context) =>
                                                    Text("complete".tr),
                                          },
                                        )),
                              ),
                            ),
                          ),
                        )
                      ])),
                  WidgetConstant.sliverPaddingVertial40,
                ],
              ),
            ),
          ),
        );
      },
      repositoryId: 'transaction',
    );
  }
}

class _TransactionNativeTransferOperationView extends StatelessWidget {
  const _TransactionNativeTransferOperationView(
      {required this.operation, required this.route});
  final SwapRouteTransactionTransferDetails operation;
  final SwapRoute route;

  @override
  Widget build(BuildContext context) {
    return APPExpansionListTile(
      title: operation.tokenAddress != null
          ? Text('token_transfer'.tr,
              style: context.onPrimaryTextTheme.bodyMedium)
          : Text('transfer'.tr, style: context.onPrimaryTextTheme.bodyMedium),
      children: [
        ContainerWithBorder(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("source".tr, style: context.onPrimaryTextTheme.titleMedium),
              WidgetConstant.height8,
              ContainerWithBorder(
                backgroundColor: context.onPrimaryContainer,
                child: CopyableTextWidget(
                  text: operation.sourceAddress,
                  color: context.primaryContainer,
                ),
              ),
              WidgetConstant.height20,
              Text("destionation".tr,
                  style: context.onPrimaryTextTheme.titleMedium),
              WidgetConstant.height8,
              ContainerWithBorder(
                backgroundColor: context.onPrimaryContainer,
                onRemove: () {},
                enableTap: false,
                onRemoveWidget: BarcodeImageIconView(
                  data: operation.destinationAddress,
                  color: context.primaryContainer,
                ),
                child: CopyableTextWidget(
                  text: operation.destinationAddress,
                  color: context.primaryContainer,
                ),
              ),
              WidgetConstant.height20,
              Text("amount".tr, style: context.onPrimaryTextTheme.titleMedium),
              WidgetConstant.height8,
              ContainerWithBorder(
                backgroundColor: context.onPrimaryContainer,
                child: CoinPriceView(
                  token: route.quote.sourceAsset,
                  amount: operation.amount,
                  symbolColor: context.primaryContainer,
                  style: context.primaryTextTheme.titleMedium,
                  showTokenImage: true,
                ),
              ),
              ConditionalWidget(
                enable: operation.tokenAddress != null,
                onActive: (context) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WidgetConstant.height20,
                    Text("token".tr,
                        style: context.onPrimaryTextTheme.titleMedium),
                    WidgetConstant.height8,
                    ContainerWithBorder(
                      backgroundColor: context.onPrimaryContainer,
                      child: CopyableTextWidget(
                          text: operation.tokenAddress!,
                          color: context.primaryContainer),
                    ),
                  ],
                ),
              ),
              ConditionalWidget(
                enable: operation.memo != null,
                onActive: (context) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WidgetConstant.height20,
                    Text("memo".tr,
                        style: context.onPrimaryTextTheme.titleMedium),
                    WidgetConstant.height8,
                    ContainerWithBorder(
                      backgroundColor: context.onPrimaryContainer,
                      child: CopyableTextWidget(
                          text: operation.memo!,
                          maxLines: 2,
                          color: context.primaryContainer),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class _TransactionNativeContractOperationView extends StatelessWidget {
  const _TransactionNativeContractOperationView(
      {required this.operation, required this.route});
  final SwapRouteTransactionContractDetails operation;
  final SwapRoute route;

  @override
  Widget build(BuildContext context) {
    return APPExpansionListTile(
      title: Text('contract_intraction'.tr),
      children: [
        ContainerWithBorder(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("source".tr, style: context.onPrimaryTextTheme.titleMedium),
              WidgetConstant.height8,
              ContainerWithBorder(
                backgroundColor: context.onPrimaryContainer,
                child: CopyableTextWidget(
                  text: operation.sourceAddress,
                  color: context.primaryContainer,
                ),
              ),
              WidgetConstant.height20,
              Text("contract".tr,
                  style: context.onPrimaryTextTheme.titleMedium),
              WidgetConstant.height8,
              ContainerWithBorder(
                backgroundColor: context.onPrimaryContainer,
                child: CopyableTextWidget(
                  text: operation.contractAddress,
                  color: context.primaryContainer,
                ),
              ),
              ConditionalWidget(
                  enable: operation.amount != null,
                  onActive: (context) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WidgetConstant.height20,
                        Text("amount".tr,
                            style: context.onPrimaryTextTheme.titleMedium),
                        WidgetConstant.height8,
                        ContainerWithBorder(
                          backgroundColor: context.onPrimaryContainer,
                          child: CoinPriceView(
                            token: route.quote.sourceAsset,
                            amount: operation.amount!,
                            symbolColor: context.primaryContainer,
                            style: context.primaryTextTheme.titleMedium,
                          ),
                        ),
                      ],
                    );
                  }),
              WidgetConstant.height20,
              Text("function".tr,
                  style: context.onPrimaryTextTheme.titleMedium),
              WidgetConstant.height8,
              ContainerWithBorder(
                backgroundColor: context.onPrimaryContainer,
                child: CopyableTextWidget(
                    text: operation.functionName,
                    color: context.primaryContainer),
              ),
              WidgetConstant.height20,
              Text("input".tr, style: context.onPrimaryTextTheme.titleMedium),
              WidgetConstant.height8,
              ContainerWithBorder(
                backgroundColor: context.onPrimaryContainer,
                child: CopyableTextWidget(
                    text: operation.data,
                    color: context.primaryContainer,
                    maxLines: 3),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class _CfChannelInformation extends StatelessWidget {
  final SwapRouteCfGeneralTransactionBuilderParam channel;
  const _CfChannelInformation({required this.channel});

  @override
  Widget build(BuildContext context) {
    return APPExpansionListTile(
      title: Text('channel_information'.tr,
          style: context.onPrimaryTextTheme.bodyMedium),
      children: [
        ContainerWithBorder(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("channel_id".tr,
                  style: context.onPrimaryTextTheme.titleMedium),
              WidgetConstant.height8,
              ContainerWithBorder(
                backgroundColor: context.onPrimaryContainer,
                onRemove: () {},
                enableTap: false,
                onRemoveWidget: LaunchBrowserIcon(
                    url: channel.channelUrl, color: context.primaryContainer),
                child: CopyableTextWidget(
                  text: channel.channelUrl,
                  color: context.primaryContainer,
                ),
              ),
              WidgetConstant.height20,
              Text("expiration_time".tr,
                  style: context.onPrimaryTextTheme.titleMedium),
              WidgetConstant.height8,
              ContainerWithBorder(
                backgroundColor: context.onPrimaryContainer,
                child: Text(channel.channel.srcChainExpiryBlock,
                    style: context.primaryTextTheme.bodyMedium),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
