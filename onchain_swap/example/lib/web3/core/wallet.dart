import 'dart:async';
import 'package:onchain_swap/onchain_swap.dart';
import 'package:example/app/euqatable/equatable.dart';
import 'package:example/app/image/image.dart';

enum Web3WalletProtocol {
  eip1193("EIP-1193"),
  eip6963("EIP-6963"),
  walletStandard("Wallet Standard");

  const Web3WalletProtocol(this.name);

  final String name;
  bool get isWalletStandard => this == walletStandard;
}

enum Web3WalletStatus {
  connect,
  noAccount,
  wrongNetwork,
  discconect;

  bool get isConnnet => this == connect;
}

abstract class Web3WalletAccount<ADDRESS> with Equatable {
  final ADDRESS address;
  final String addressStr;
  const Web3WalletAccount({required this.address, required this.addressStr});
  @override
  List get variabels => [addressStr];
}

abstract class Web3Wallet<NETWORK extends SwapNetwork,
    ADDRESS extends Web3WalletAccount> extends Equatable {
  final String name;
  final BaseAPPImage? icon;
  final Web3WalletProtocol protocol;
  final NETWORK network;
  Web3Wallet({
    required String? walletName,
    required this.icon,
    required this.protocol,
    required this.network,
  }) : name = walletName ?? "Unknown";

  bool get allowMultiSelect;
  Web3WalletStatus get status;
  List<ADDRESS> get accounts;
  List<ADDRESS> get selectedAddresses;
  void listenOnEvents();
  void disposeEvents();
  Future<bool> connect({bool silent = false});
  void updateStatus(Web3WalletStatus status);
  void setSelectAccounts();
  void updateAccounts(List<ADDRESS> accounts);

  void addOrChangeSelectedAddress(ADDRESS address);
  Stream<List<ADDRESS>> onChange();
  void dispose();
}
