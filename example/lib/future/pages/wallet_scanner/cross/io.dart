import 'package:onchain_swap_example/future/pages/wallet_scanner/state/wallet_scanner.dart';
import 'package:onchain_swap_example/future/state_managment/state_managment.dart';
import 'package:flutter/material.dart';

State<WalletScannerView> walletScannerState() => _IoWalletScannerViewState();

class _IoWalletScannerViewState extends State<WalletScannerView>
    with SafeState {
  @override
  Widget build(BuildContext context) {
    return Text("unsuported io");
  }
}
