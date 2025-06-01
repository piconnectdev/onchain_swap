// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:js_interop';
import 'package:onchain_swap_example/app/app.dart';
import 'package:onchain_swap_example/app/constants/constants.dart';
import 'package:onchain_swap_example/future/pages/wallet_scanner/state/wallet_scanner.dart';
import 'package:onchain_swap_example/future/state_managment/state_managment.dart';
import 'package:onchain_swap_example/future/widgets/custom_widgets.dart';
import 'package:onchain_swap_example/web3/core/wallet.dart';
import 'package:onchain_swap_example/web3/cross/web/types/types.dart';
import 'package:onchain_swap_example/web3/wallet_tracker/core/core.dart';
import 'package:flutter/material.dart';

@JS()
extension type JSWalletStandardRegisterWallet(JSAny _) implements JSAny {
  external set register(JSFunction wallet);
}

@JS()
extension type JSCustomEvent(JSAny _) implements JSAny {
  external void detail(JSWalletStandardRegisterWallet event);
  @JS("detail")
  external JSEIP6963? get detail_;
}
State<WalletScannerView> walletScannerState() => _WebWalletScannerViewState();

class _WebWalletScannerViewState extends State<WalletScannerView>
    with SafeState<WalletScannerView> {
  final GlobalKey<PageProgressState> progressKey =
      GlobalKey<PageProgressState>();
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? controller;
  GlobalKey<ScaffoldMessengerState> messnegerKey = GlobalKey();
  late final WalletTracker tracker;

  Future<void> connect(Web3Wallet wallet) async {
    try {
      await tracker.connect(wallet: wallet, silent: false);
    } on JSError catch (e) {
      _shwoRequestStatus(e.message ?? 'wallet_request_unknown_err'.tr);
    } catch (e) {
      _shwoRequestStatus('wallet_request_unknown_err'.tr);
    }
  }

  // List<Web3Wallet> wallets = [];

  void _shwoRequestStatus(String error) async {
    final key = messnegerKey.currentState;
    controller ??=
        key?.showSnackBar(_requestStatusView(context: context, error: error));
  }

  void onTrckerListener(Web3Wallet? wallet) {
    updateState();
  }

  @override
  void safeDispose() {
    super.safeDispose();
    tracker.addListener(onTrckerListener);
  }

  void disconnect() {
    tracker.disconnect();
  }

  @override
  void onInitOnce() {
    super.onInitOnce();
    tracker = widget.tracker;
    tracker.addListener(onTrckerListener);
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: messnegerKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text("manage_wallets".tr),
        ),
        body: CustomScrollView(
          slivers: [
            SliverConstraintsBoxView(
                padding: WidgetConstant.paddingHorizontal20,
                sliver: ConditionalWidget(
                  enable: tracker.activeWallet != null,
                  onActive: (context) => _SelectWalletView(
                      wallet: tracker.activeWallet!, disconnect: disconnect),
                  onDeactive: (context) => EmptyItemSliverWidgetView(
                    isEmpty: tracker.wallets.isEmpty,
                    subject: 'no_wallet_detected'.tr,
                    icon: Icons.wallet,
                    itemBuilder: (context) => SliverList.builder(
                        itemBuilder: (context, index) {
                          final wallet = tracker.wallets[index];
                          return ContainerWithBorder(
                              child: Row(children: [
                            CircleAssetImageView(wallet.icon,
                                radius: APPConst.circleRadius25),
                            Expanded(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(wallet.name,
                                    style:
                                        context.onPrimaryTextTheme.bodyMedium),
                                Text(wallet.protocol.name)
                              ],
                            )),
                            ConditionalWidget(
                              enable: tracker.activeWallet == null,
                              onActive: (context) => ElevatedButton(
                                  onPressed: () => connect(wallet),
                                  child: Text("connect".tr)),
                            )
                          ]));
                        },
                        itemCount: tracker.wallets.length),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}

class _SelectWalletView extends StatelessWidget {
  final Web3Wallet wallet;
  final DynamicVoid disconnect;
  const _SelectWalletView({required this.disconnect, required this.wallet});

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(slivers: [
      SliverPinnedHeader(
          child: ContainerWithBorder(
              child: Row(children: [
        CircleAssetImageView(wallet.icon, radius: APPConst.circleRadius25),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(wallet.name, style: context.onPrimaryTextTheme.bodyMedium),
            Text(wallet.protocol.name)
          ],
        )),
        ElevatedButton(onPressed: disconnect, child: Text("disconnect".tr))
      ]))),
      SliverToBoxAdapter(
        child: ConditionalWidget(
          enable: wallet.status == Web3WalletStatus.connect,
          onActive: (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WidgetConstant.height20,
              Text("accounts".tr, style: context.textTheme.titleMedium),
              Text("select_account_desc".tr),
              WidgetConstant.height8,
              ...List.generate(wallet.accounts.length, (i) {
                final account = wallet.accounts[i];
                return ContainerWithBorder(
                  enableTap: true,
                  onRemove: () {},
                  onRemoveWidget: CopyTextIcon(
                    dataToCopy: account.addressStr,
                    color: context.onPrimaryContainer,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          account.addressStr,
                          style: context.onPrimaryTextTheme.bodyMedium,
                        ),
                      ),
                      APPCheckBox(
                        value: wallet.selectedAddresses.contains(account),
                        onChanged: (p0) =>
                            wallet.addOrChangeSelectedAddress(account),
                      )
                    ],
                  ),
                );
              })
            ],
          ),
          onDeactive: (context) => ConditionalWidget(
            onActive: (context) =>
                ErrorTextContainer(error: "no_wallet_accounts_found".tr),
            enable: wallet.status == Web3WalletStatus.noAccount ||
                wallet.protocol.isWalletStandard,
            onDeactive: (context) {
              return ErrorTextContainer(error: "no_wallet_accounts_found".tr);
            },
          ),
        ),
      )
    ]);
  }
}

SnackBar _requestStatusView(
    {required BuildContext context, required String error}) {
  return SnackBar(
      duration: const Duration(seconds: 5),
      content: Row(
        children: [
          Expanded(child: Text(error)),
          Icon(Icons.error, color: context.colors.error)
        ],
      ));
}
