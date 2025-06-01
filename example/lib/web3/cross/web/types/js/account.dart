import 'dart:async';

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_swap/onchain_swap.dart';
import 'package:onchain_swap_example/web3/core/wallet.dart';

class JSWeb3WalletAccount<ADDRESS, JSADDRESS>
    extends Web3WalletAccount<ADDRESS> {
  final JSADDRESS jsAddress;
  const JSWeb3WalletAccount(
      {required this.jsAddress,
      required super.address,
      required super.addressStr});
  @override
  List get variabels => [addressStr];
}

abstract class JSWeb3Wallet<NETWORK extends SwapNetwork, ADDRESS, JSADDRESS>
    extends Web3Wallet<NETWORK, JSWeb3WalletAccount<ADDRESS, JSADDRESS>> {
  JSWeb3Wallet(
      {required super.walletName,
      required super.icon,
      required super.protocol,
      required super.network,
      List<JSWeb3WalletAccount<ADDRESS, JSADDRESS>> accounts = const []})
      : _accounts = accounts.immutable;

  @override
  bool get allowMultiSelect => false;
  Web3WalletStatus _status = Web3WalletStatus.discconect;
  @override
  Web3WalletStatus get status => _status;
  List<JSWeb3WalletAccount<ADDRESS, JSADDRESS>> _accounts;
  @override
  List<JSWeb3WalletAccount<ADDRESS, JSADDRESS>> get accounts => _accounts;
  List<JSWeb3WalletAccount<ADDRESS, JSADDRESS>> _selectedAddresses =
      <JSWeb3WalletAccount<ADDRESS, JSADDRESS>>[].immutable;
  @override
  List<JSWeb3WalletAccount<ADDRESS, JSADDRESS>> get selectedAddresses =>
      _selectedAddresses;
  final StreamController<List<JSWeb3WalletAccount<ADDRESS, JSADDRESS>>>
      _onChage = StreamController<
          List<JSWeb3WalletAccount<ADDRESS, JSADDRESS>>>.broadcast();
  @override
  void listenOnEvents() {}
  @override
  void disposeEvents() {}

  @override
  Future<bool> connect({bool silent = false}) async => false;

  @override
  void updateStatus(Web3WalletStatus status) {
    _status = status;
    _onChage.add(_selectedAddresses);
  }

  void setAccounts(List<JSWeb3WalletAccount<ADDRESS, JSADDRESS>> accounts) {
    _accounts = accounts.toImutableList;
    setSelectAccounts();
  }

  @override
  void setSelectAccounts() {
    _selectedAddresses = {
      for (final i in _accounts)
        if (_selectedAddresses.contains(i)) i
    }.toImutableList;
    if (_selectedAddresses.isEmpty) {
      if (allowMultiSelect) {
        _selectedAddresses = _accounts.toImutableList;
      } else {
        _selectedAddresses = (_accounts.isEmpty
                ? <JSWeb3WalletAccount<ADDRESS, JSADDRESS>>[]
                : [_accounts.first])
            .toImutableList;
      }
    }
  }

  @override
  void updateAccounts(List<JSWeb3WalletAccount<ADDRESS, JSADDRESS>> accounts) {
    if (accounts.isEmpty && status == Web3WalletStatus.discconect) return;
    setAccounts(accounts);
    if (_selectedAddresses.isEmpty) {
      updateStatus(Web3WalletStatus.noAccount);
    } else {
      updateStatus(Web3WalletStatus.connect);
    }
  }

  @override
  void addOrChangeSelectedAddress(
      JSWeb3WalletAccount<ADDRESS, JSADDRESS> address) {
    if (accounts.contains(address)) {
      if (allowMultiSelect) {
        _selectedAddresses = {address, ..._selectedAddresses}.toImutableList;
      } else {
        _selectedAddresses = [address].toImutableList;
      }
      emitChanged();
    }
  }

  @override
  Stream<List<JSWeb3WalletAccount<ADDRESS, JSADDRESS>>> onChange() {
    return _onChage.stream;
  }

  void emitChanged() {
    _onChage.add(_selectedAddresses);
  }

  @override
  void dispose() {
    disposeEvents();
    _onChage.close();
  }

  @override
  List get variabels => [name, protocol];
}
