import 'dart:async';
import 'package:on_chain_swap/on_chain_swap.dart' show SwapNetwork;
import 'package:onchain_swap_example/web3/core/wallet.dart';

import '../platform_impl/cross.dart'
    if (dart.library.js_interop) '../platform_impl/web.dart'
    if (dart.library.io) '../platform_impl/io.dart';

typedef WALLETLISTENER = void Function(Web3Wallet? wallet);

abstract class WalletTracker {
  abstract final SwapNetwork network;
  List<Web3Wallet> get wallets;
  Web3Wallet? get activeWallet;

  Future<bool> connect({required Web3Wallet wallet, bool silent = false});
  Future<void> connectSilent();
  static WalletTracker instance({required SwapNetwork network}) =>
      walletTracker(network: network);
  void disconnect();
  void dispose();
  void addListener(WALLETLISTENER listener);
  void removeListener(WALLETLISTENER listener);
}
