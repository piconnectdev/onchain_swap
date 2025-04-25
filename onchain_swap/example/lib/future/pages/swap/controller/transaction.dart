import 'dart:async';
import 'package:blockchain_utils/bip/bip/conf/core/coin_conf.dart';
import 'package:blockchain_utils/helper/extensions/extensions.dart';
import 'package:example/api/services/types/app_client.dart';
import 'package:example/app/http/impl/impl.dart';
import 'package:example/app/synchronized/basic_lock.dart';
import 'package:example/app/types/types.dart';
import 'package:example/app/utils/method.dart';
import 'package:example/future/widgets/widgets/progress_bar/progress.dart';
import 'package:example/web3/core/wallet.dart';
import 'package:example/web3/wallet_tracker/core/core.dart';
import 'package:flutter/material.dart';
import 'package:onchain_swap/onchain_swap.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:example/api/utils/utils.dart';
import 'package:example/api/services/socket/core/socket_provider.dart';
import 'package:example/api/services/types/types.dart';
import 'package:example/app/error/exception/app.dart';
import 'package:example/future/state_managment/state_managment.dart';
import 'package:example/repository/network.dart';
import 'package:example/swap/swap.dart';

typedef SELECTSERVICE = Future<ServiceInfo?> Function(
    SwapNetwork network, ServiceInfo? service);

class SwapTransactionStateController extends StateController
    with NetworkRepository, HttpImpl {
  SwapTransactionStateController(
      {required this.transaction, required this.route});
  final SwapRouteTransactionBuilder transaction;
  final SwapRouteWithBps route;
  final _lock = SynchronizedLock();
  AppClient? _client;
  final GlobalKey<PageProgressState> progressKey = GlobalKey();
  TransactionOperationStep? _step;
  TransactionOperationStep? get step => _step;
  WalletTracker? _walletTracker;
  Web3Wallet? _wallet;
  bool get inProgress => _step != null;
  bool get hasWallet => _wallet != null;
  SwapNetwork get network => transaction.route.quote.sourceAsset.network;
  Future<bool> onPop(FuncFutureNullableBoold callback) async {
    if (allowPop) return true;
    final pop = await callback();
    if (pop == true) {
      allowPop = true;
      notify();
      return MethodUtils.after(() async => true);
    }
    return false;
  }

  String? _latestError;
  String? get latestError => _latestError;
  bool allowPop = false;
  void _onUpdateState(TransactionOperationStep step,
      {String? transactionHash}) {
    _step = step;

    if (step == TransactionOperationStep.txHash) {
      allowPop = true;
      progressKey.success(
          backToIdle: false,
          progressWidget: SuccessTransactionTextView(
              txIds: [transactionHash ?? ''], network: network));
    }
    notify();
  }

  Future<AppClient?> _loadClient(SELECTSERVICE onSelectService) async {
    final network = route.route.quote.sourceAsset.network;
    CosmosSdkChain? chainInfo;
    final service = await loadServiceProvider(network);
    final defaultService = ProviderUtils.getProvider(network);
    List<ServiceInfo> services = [
      if (service != null) service,
      ...defaultService
    ];
    switch (network.type) {
      case SwapChainType.cosmos:
        final cosmosChains = await loadCosmosChains();
        switch (network.chainType) {
          case ChainType.testnet:
            chainInfo = cosmosChains.testnet
                .firstWhereNullable((e) => e.chainId == network.identifier);
            break;
          case ChainType.mainnet:
            chainInfo = cosmosChains.mainnet
                .firstWhereNullable((e) => e.chainId == network.identifier);
            break;
        }
        if (chainInfo == null || chainInfo.fees.isEmpty) {
          throw AppException("unsupported_source_network");
        }
        services.addAll(chainInfo.bestApis.rpc.map((e) =>
            ServiceInfo(url: e.address, protocol: ServiceProtocol.http)));
        break;
      default:
    }
    for (final i in services) {
      try {
        return await ProviderUtils.buildClient(
            network: network, provider: i, cosmosChain: chainInfo);
      } catch (_) {}
    }
    final newService = await onSelectService(network, service);
    if (newService == null) return null;
    try {
      return await ProviderUtils.buildClient(
          network: network, provider: newService, cosmosChain: chainInfo);
    } catch (_) {}
    return null;
  }

  Future<void> _signTransaction(NetworkClient client) async {
    final wallet = _wallet;
    if (wallet == null) {
      throw AppException("no_wallet_detected");
    }
    switch (transaction.runtimeType) {
      case const (SwapRouteEthereumTransactionBuilder):
        return await (transaction as SwapRouteEthereumTransactionBuilder)
            .buildTransactions(
                stepsCallBack: _onUpdateState,
                client: (network) async {
                  return client.cast<EthereumClient>();
                },
                signer: (e) async {
                  return wallet as Web3SignerEthereum;
                });
      case const (SwapRouteCosmosTransactionBuilder):
        return await (transaction as SwapRouteCosmosTransactionBuilder)
            .buildTransactions(
                stepsCallBack: _onUpdateState,
                client: (network) async => client.cast<CosmosClient>(),
                signer: (e) async {
                  return wallet as Web3SignerCosmos;
                });
      case const (SwapRouteSubstrateTransactionBuilder):
        return await (transaction as SwapRouteSubstrateTransactionBuilder)
            .buildTransactions(
                stepsCallBack: _onUpdateState,
                client: (network) async => client.cast<SubstrateClient>(),
                signer: (e) async {
                  return wallet as Web3SignerSubstrate;
                });
      case const (SwapRouteSolanaTransactionBuilder):
        return await (transaction as SwapRouteSolanaTransactionBuilder)
            .buildTransactions(
                stepsCallBack: _onUpdateState,
                client: (network) async => client.cast<SolanaClient>(),
                signer: (e) async {
                  return wallet as Web3SignerSolana;
                });
      case const (SwapRouteBitcoinTransactionBuilder):
        return (transaction as SwapRouteBitcoinTransactionBuilder)
            .buildTransactions(
                stepsCallBack: _onUpdateState,
                client: (network) async => client.cast<BitcoinClient>(),
                signer: (e) async {
                  return wallet as Web3SignerBitcoin;
                });
      default:
    }
  }

  Future<void> signTransaction(SELECTSERVICE onSelectService) async {
    await _lock.synchronized(() async {
      _latestError = null;
      _step = TransactionOperationStep.client;
      allowPop = false;
      notify();
      final client = (_client ??= await _loadClient(onSelectService));
      if (client == null) {
        _step = null;
      } else {
        final r = await MethodUtils.call(() async {
          return _signTransaction(client.client);
        });
        if (r.hasError) {
          _step = null;
          _latestError = r.error;
        }
      }
      allowPop = true;
      notify();
    });
  }

  void onChangeWallet(Web3Wallet? wallet) {
    if (wallet?.network != network) {
      _wallet = null;
    } else {
      _wallet = wallet;
    }
    notify();
  }

  @override
  void init() {
    super.init();
    _walletTracker = WalletTracker.instance(network: network);
    _walletTracker?.addListener(onChangeWallet);
  }

  @override
  void ready() {
    super.ready();
    _walletTracker?.connectSilent();
  }

  @override
  void close() {
    super.close();
    _client?.close();
    _client = null;
    _walletTracker?.dispose();
    _walletTracker = null;
  }
}
