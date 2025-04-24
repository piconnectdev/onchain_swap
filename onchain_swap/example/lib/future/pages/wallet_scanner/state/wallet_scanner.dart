import 'package:example/web3/wallet_tracker/core/core.dart';
import 'package:flutter/material.dart';
import '../cross/core.dart'
    if (dart.library.js_interop) '../cross/web.dart'
    if (dart.library.io) '../cross/io.dart';

class WalletScannerView extends StatefulWidget {
  final WalletTracker tracker;
  const WalletScannerView({required this.tracker, super.key});

  @override
  // ignore: no_logic_in_create_state
  State<WalletScannerView> createState() => walletScannerState();
}
