import 'package:example/future/pages/swap/widget/review_transaction.dart';
import 'package:example/future/pages/wallet_scanner/state/wallet_scanner.dart';
import 'package:flutter/material.dart';
import 'package:example/future/pages/swap/controller/swap.dart';
import 'package:example/future/state_managment/state_managment.dart';
import 'package:example/future/widgets/custom_widgets.dart';

class SwapAddressesView extends StatelessWidget {
  final SwapStateController controller;
  const SwapAddressesView({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: WidgetConstant.paddingHorizontal10,
      child: Column(
        children: [
          AppTextField(
            initialValue: controller.sourceAddress,
            key: controller.sourceAddressKey,
            label: 'source_address'.tr,
            pasteIcon: true,
            maxLines: 1,
            prefixIcon: SizedBox(
              width: 25,
              height: 25,
              child: Center(
                child: CircleNetworkImageView(controller.sourceAsset?.network,
                    radius: 12),
              ),
            ),
            hint:
                "eg_example".tr.replaceOne(controller.sourceAddressHint ?? ''),
            onChanged: controller.onChangeSourceAddress,
            validator: controller.validateSourceAddress,
          ),
          WidgetConstant.height20,
          AppTextField(
              initialValue: controller.destinationAddress,
              pasteIcon: true,
              maxLines: 1,
              prefixIcon: SizedBox(
                width: 25,
                height: 25,
                child: Center(
                  child: CircleNetworkImageView(
                      controller.destinationAsset?.network,
                      radius: 12),
                ),
              ),
              key: controller.destinationAddressKey,
              label: "destination_address".tr,
              suffixIcon: ConditionalWidget(
                  onActive: (context) {
                    return IconButton(
                        onPressed: () {
                          context.openDialogPage(
                            label: '',
                            child: (context) => WalletScannerView(
                                tracker: controller.destinalWalletTracker!),
                          );
                        },
                        icon: Icon(Icons.wallet));
                  },
                  enable: controller.destinalWalletTracker != null),
              onChanged: controller.onChangeDestinationAddress,
              validator: controller.validateDestinationAddress,
              hint: "eg_example"
                  .tr
                  .replaceOne(controller.destinationAddressHint ?? '')),
          WidgetConstant.height20,
          WidgetConstant.height20,
          Shimmer(
            count: 1,
            enable: controller.page == SwapPage.swap,
            onActive: (enable, context) => FixedElevatedButton(
              height: 70,
              width: context.mediaQuery.size.width,
              onPressed: () {
                controller.createSwapTransaction(
                    onPage: (transaction, route, tracker) async {
                  return context.openDialogPage(
                      label: '',
                      child: (context) {
                        return TransactionReviewView(
                            transaction: transaction, route: route);
                      });
                });
              },
              child: APPAnimated(
                isActive: enable,
                onActive: (context) => Text("swap_now".tr),
                onDeactive: (context) => Text("generating_transaction".tr),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
