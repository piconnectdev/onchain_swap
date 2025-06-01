import 'dart:async';

import 'package:on_chain_swap/on_chain_swap.dart' show SwapNetwork;
import 'package:onchain_swap_example/web3/core/wallet.dart';
import 'package:onchain_swap_example/web3/wallet_tracker/core/core.dart';

WalletTracker walletTracker({required SwapNetwork network}) =>
    IOWalletTracker();

class IOWalletTracker implements WalletTracker {
  @override
  SwapNetwork get network => throw UnimplementedError();

  @override
  void disconnect() {}

  @override
  void dispose() {}

  @override
  Future<bool> connect(
      {required Web3Wallet<SwapNetwork, dynamic> wallet,
      bool silent = false}) async {
    return false;
  }

  Stream<Null> listeOnChange() {
    throw UnimplementedError();
  }

  @override
  Future<void> connectSilent() async {}

  @override
  void addListener(WALLETLISTENER listener) {}

  @override
  void removeListener(WALLETLISTENER listener) {}

  @override
  Web3Wallet<SwapNetwork, Web3WalletAccount>? get activeWallet =>
      throw UnimplementedError();

  @override
  List<Web3Wallet<SwapNetwork, Web3WalletAccount>> get wallets =>
      throw UnimplementedError();
}
