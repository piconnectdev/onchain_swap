import 'dart:async';
import 'dart:js_interop';

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:onchain_swap/onchain_swap.dart';
import 'package:onchain_swap_example/app/synchronized/basic_lock.dart';
import 'package:onchain_swap_example/future/pages/wallet_scanner/cross/web.dart';
import 'package:onchain_swap_example/web3/core/wallet.dart';
import 'package:onchain_swap_example/web3/cross/web/types/types.dart';
import 'package:onchain_swap_example/web3/cross/web/wallets/wallets.dart';
import 'package:onchain_swap_example/web3/wallet_tracker/core/core.dart';
import 'package:onchain_bridge/web/web.dart';

WalletTracker walletTracker({required SwapNetwork network}) =>
    WebWalletTracker(network: network);

class WebWalletTracker implements WalletTracker {
  @override
  final SwapNetwork network;
  WebWalletTracker({required this.network});
  final _lock = SynchronizedLock();
  Set<Web3Wallet> _wallets = {};
  @override
  List<Web3Wallet> get wallets => _wallets.toList();
  StreamSubscription<Web3Wallet>? _subscription;
  StreamSubscription<List<Web3WalletAccount>>? _onSelectWalletChange;
  Web3Wallet? _activeWallet;
  @override
  Web3Wallet? get activeWallet => _activeWallet;
  final Set<WALLETLISTENER> _listeners = {};
  void _emitListeners() {
    final wallet = _activeWallet;
    for (final i in [..._listeners]) {
      i(wallet);
    }
  }

  @override
  void addListener(WALLETLISTENER listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(WALLETLISTENER listener) {
    _listeners.remove(listener);
  }

  Web3Wallet? isWalletStandard(JSWalletStandard? wallet) {
    if (wallet == null) return null;
    if (!wallet.isWalletStandard()) {
      return null;
    }
    switch (network.type) {
      case SwapChainType.ethereum:
        return JSWeb3WalletWalletStandardEthereum.fromJs(
            wallet: wallet, network: network.cast());
      case SwapChainType.solana:
        return JSWeb3WalletWalletStandardSolana.fromJs(
            wallet: wallet, network: network.cast());
      case SwapChainType.bitcoin:
        return JSWeb3WalletWalletStandardBitcoin.fromJs(
            wallet: wallet, network: network.cast());
      case SwapChainType.cosmos:
        return JSWeb3WalletWalletStandardCosmos.fromJs(
            wallet: wallet, network: network.cast());
      case SwapChainType.polkadot:
        return JSWeb3WalletWalletStandardSubstrate.fromJs(
            wallet: wallet, network: network.cast());
    }
  }

  Web3Wallet? isEIP1193(JSEIP1193? wallet) {
    if (wallet == null) return null;
    if (!wallet.isEIP1193()) {
      return null;
    }
    switch (network.type) {
      case SwapChainType.ethereum:
        return JSWeb3WalletEIP1193Ethereum.fromJs(
            wallet: wallet, network: network.cast());
      default:
        return null;
    }
  }

  Web3Wallet? isEIP6963(JSEIP6963? wallet) {
    if (wallet == null) return null;
    if (!wallet.isEIP6963()) {
      return null;
    }
    switch (network.type) {
      case SwapChainType.ethereum:
        return JSWeb3WalletEIP6963Ethereum.fromJs(
            wallet: wallet, network: network.cast());
      default:
        return null;
    }
  }

  void _listenOnWallets() {
    Stream<Web3Wallet> listenOnWallets() {
      StreamController<Web3Wallet> controller = StreamController<Web3Wallet>();
      final registerEvent = JSWalletStandardRegisterWallet(JSObject());
      Timer? timer;
      registerEvent.register = (JSWalletStandard? wallet) {
        if (wallet.isUndefinedOrNull) return;
        final walletStandard = isWalletStandard(wallet);
        if (walletStandard == null) return;
        controller.add(walletStandard);
      }.toJS;
      final walletsStandard = jsWindow
          .streamObject<JSCustomEvent>('wallet-standard:register-wallet')
          .listen((wallet) {
        try {
          wallet.detail(registerEvent);
        } catch (_) {}
      });
      timer = Timer.periodic(const Duration(seconds: 1), (e) {
        if (ethereum.isUndefinedOrNull) return;
        final walletStandard = isEIP1193(ethereum);
        if (walletStandard == null) return;
        controller.add(walletStandard);
        e.cancel();
      });
      final eip6963 = jsWindow
          .streamObject<JSCustomEvent>('eip6963:announceProvider')
          .listen((details) {
        if (details.isUndefinedOrNull || details.detail_.isUndefinedOrNull) {
          return;
        }
        final isEip6963 = isEIP6963(details.detail_);
        if (isEip6963 == null) return;
        controller.add(isEip6963);
      });
      controller.onCancel = () {
        walletsStandard.cancel();
        eip6963.cancel();
        timer?.cancel();
        timer = null;
      };
      CustomEvent event = CustomEvent("wallet-standard:app-ready",
          EventInit(bubbles: false, cancelable: false, detail: null));
      jsWindow.dispatchEvent(event);
      event = CustomEvent("eip6963:requestProvider",
          EventInit(bubbles: false, cancelable: false, detail: null));
      jsWindow.dispatchEvent(event);
      return controller.stream;
    }

    _subscription = listenOnWallets().listen(_onWallet);
  }

  void _onUpdateActiveWallet(List<Web3WalletAccount> accounts) {
    _emitListeners();
  }

  void _onWallet(Web3Wallet wallet) {
    _wallets = {..._wallets, wallet}.toImutableSet;
    connect(wallet: wallet, silent: true);
    _emitListeners();
  }

  @override
  void disconnect() {
    _activeWallet?.disposeEvents();
    _activeWallet = null;
    _onSelectWalletChange?.cancel();
    _onSelectWalletChange = null;
    _emitListeners();
  }

  @override
  void dispose() {
    disconnect();
    _subscription?.cancel();
    _subscription = null;
    for (final i in _wallets) {
      i.dispose();
    }
    _wallets = {};
    _listeners.clear();
  }

  @override
  Future<bool> connect(
      {required Web3Wallet<SwapNetwork, Web3WalletAccount> wallet,
      bool silent = false}) async {
    try {
      return await _lock.synchronized(() async {
        if (_activeWallet != null) return true;
        final connect = await wallet.connect(silent: silent);
        if (silent && !connect) return false;
        _activeWallet = wallet;
        _onSelectWalletChange = wallet.onChange().listen(_onUpdateActiveWallet);
        wallet.listenOnEvents();

        return true;
      });
    } finally {
      _emitListeners();
    }
  }

  @override
  Future<void> connectSilent() async {
    _listenOnWallets();
  }
}
