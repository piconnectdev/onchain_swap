import 'dart:async';
import 'package:blockchain_utils/helper/extensions/extensions.dart';
import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:onchain_swap_example/app/models/models/setting.dart';
import 'package:on_chain_swap/onchain_swap.dart';
import 'package:onchain_swap_example/app/constants/constants.dart';
import 'package:onchain_swap_example/app/live_listener/live.dart';
import 'package:onchain_swap_example/app/synchronized/basic_lock.dart';
import 'package:onchain_swap_example/app/utils/method.dart';
import 'package:onchain_swap_example/future/state_managment/state_managment.dart';
import 'package:onchain_swap_example/future/text_field/input_formaters.dart';
import 'package:onchain_swap_example/future/widgets/widgets/progress_bar/progress.dart';
import 'package:onchain_swap_example/future/widgets/widgets/text_field.dart';
import 'package:onchain_swap_example/repository/network.dart';
import 'package:onchain_swap_example/swap/swap.dart';
import 'package:onchain_swap_example/web3/core/wallet.dart';
import 'package:onchain_swap_example/web3/wallet_tracker/core/core.dart';
import 'package:flutter/material.dart';

enum SwapRouteStatus {
  pending,
  success,
  failed;

  bool get isPending => this == pending;
  bool get error => this == failed;
}

typedef ONREVIEWTX = Future<void> Function(
    SwapRouteTransactionBuilder, SwapRouteWithBps, WalletTracker?);

enum SwapPage { swap, review }

typedef ONOPENPAGE = void Function(SwapRouteTransactionBuilder);
mixin SwapStateController on StateController, NetworkRepository {
  void streamPrices();
  APPSetting get appSetting;
  final GlobalKey<PageProgressState> progressKey = GlobalKey();
  final _lock = SynchronizedLock();
  late SwapServiceApi _api;

  final CurrencyTextEdittingController amountController =
      CurrencyTextEdittingController(text: '');
  WalletTracker? _sourceWalletTracker;
  WalletTracker? _destinalWalletTracker;
  WalletTracker? get sourceWalletTracker => _sourceWalletTracker;
  WalletTracker? get destinalWalletTracker => _destinalWalletTracker;
  Map<SwapNetwork, Set<BaseSwapAsset>> _sourceAssets = {};
  Map<SwapNetwork, Set<BaseSwapAsset>> get sourceAssets => _sourceAssets;
  Map<SwapNetwork, Set<BaseSwapAsset>> _destinationAssets = {};
  Map<SwapNetwork, Set<BaseSwapAsset>> get destinationAssets =>
      _destinationAssets;
  List<BaseSwapAsset> get allAssets =>
      _sourceAssets.values.expand((e) => e).toList();

  final GlobalKey<AppTextFieldState> sourceAddressKey = GlobalKey();
  final GlobalKey<AppTextFieldState> destinationAddressKey = GlobalKey();
  Live<SwapAmount?> inputPrice = Live(null);
  BaseSwapAsset? sourceAsset;
  BaseSwapAsset? destinationAsset;
  final Cancelable _cancelable = Cancelable();

  APPSwapRoutes? _currentRoute;
  APPSwapRoutes? get currentRoute => _currentRoute;
  bool get hasRoute => _currentRoute != null;
  SwapRouteStatus _status = SwapRouteStatus.success;
  SwapRouteStatus get status => _status;

  String? _destinationAddressHint;
  String? get destinationAddressHint => _destinationAddressHint;
  String? _sourceAddressHint;
  String? get sourceAddressHint => _sourceAddressHint;

  String _sourceAddress = '';
  String _destinationAddress = '';
  String get sourceAddress => _sourceAddress;
  String get destinationAddress => _destinationAddress;

  List<RouteError> _errors = [];
  List<RouteError> get errors => _errors;

  final GlobalKey<FormState> formKey = GlobalKey();

  final Map<SwapChainType, Web3Wallet> _wallets = {};
  Map<SwapChainType, Web3Wallet> get wallets => _wallets;

  SwapPage _page = SwapPage.swap;
  SwapPage get page => _page;
  String? _txError;
  String? get txError => _txError;

  double tolerance = 2.0;

  void onChangeTol(double n) {
    tolerance = n;
    notify();
    _onAmountChanged();
  }

  SwapAmount? getTokenPrice(String amount, BaseSwapAsset token);

  SwapAmount? _inputPrice() {
    final asset = sourceAsset;
    if (asset == null) return null;
    return getTokenPrice(amountController.getText(), asset);
  }

  Timer? _timer;
  void _listenChangeAmount() {
    inputPrice.value = _inputPrice();
    inputPrice.notify();
    _timer?.cancel();
    _timer = Timer(APPConst.oneSecoundDuration, _onAmountChanged);
  }

  void _updateSourceAddress({String address = ''}) {
    _sourceAddress = address;
    sourceAddressKey.currentState?.updateText(address);
  }

  void onChangeSourceAddress(String v) {
    _sourceAddress = v;
    _shouldRebuildRoute();
  }

  void _updateDestinationAddress({String address = ''}) {
    _destinationAddress = address;
    destinationAddressKey.currentState?.updateText(address);
  }

  void onChangeDestinationAddress(String v) {
    _destinationAddress = v;
    _shouldRebuildRoute();
  }

  String? _getSourceAddress() {
    try {
      final source = sourceAsset;
      if (source == null) return null;
      return SwapUtils.validateNetworkAddress(source.network, _sourceAddress);
    } catch (e) {
      return null;
    }
  }

  String? _getDestinationAddress() {
    try {
      final source = destinationAsset;
      if (source == null) return null;
      return SwapUtils.validateNetworkAddress(
          source.network, _destinationAddress);
    } catch (e) {
      return null;
    }
  }

  String? validateSourceAddress(String? address) {
    final source = sourceAsset;
    if (source == null) return "unknown_source_asset".tr;
    try {
      SwapUtils.validateNetworkAddress(source.network, address ?? '');
    } catch (e) {
      return 'invalid_network_address'.tr.replaceOne(source.network.name);
    }
    return null;
  }

  String? validateDestinationAddress(String? address) {
    final source = destinationAsset;
    if (source == null) return "unknown_destination_asset".tr;
    try {
      SwapUtils.validateNetworkAddress(source.network, address ?? '');
    } catch (e) {
      return 'invalid_network_address'.tr.replaceOne(source.network.name);
    }
    return null;
  }

  void _cleanRoute() {
    _cancelable.cancel();
    _currentRoute = null;
    _errors = <RouteError>[].immutable;
    _txError = null;
  }

  void _shouldRebuildRoute() {
    final route = currentRoute;
    if (route?.provider.service != SwapServiceType.swapKit) return;
    final source = _getSourceAddress();
    final destination = _getDestinationAddress();
    if (source == null || destination == null) return;
    if (route?.route.route.quote.sourceAddress == source &&
        route?.route.route.quote.destinationAddress == destination) {
      return;
    }
    _onAmountChanged(sourceAddress: source, destinationAddress: destination);
  }

  void updateSourceAsset(BaseSwapAsset asset) {
    if (sourceAsset == asset) return;
    if (sourceAsset?.network != asset.network) {
      _updateSourceAddress();
    }
    _destinationAssets = _api.getDestAssets(asset);
    if (!_destinationAssets.values.any((e) => e.contains(destinationAsset))) {
      destinationAsset = null;
    }
    _cleanRoute();
    _status = SwapRouteStatus.success;
    sourceAsset = asset;
    amountController.setSymbol(asset.symbol);
    _sourceAddressHint =
        "${SwapUtils.getFakeAddress(asset.network).substring(0, 16)}...";
    sourceWalletTracker?.dispose();
    _sourceWalletTracker = WalletTracker.instance(network: asset.network);
    _sourceWalletTracker?.addListener((w) {
      _lock.synchronized(() {
        if (w == null || !w.status.isConnnet) return;
        final defaultAddress = w.selectedAddresses.firstOrNull?.addressStr;
        if (defaultAddress == null) return;
        _updateSourceAddress(address: defaultAddress);
      });
    });
    _sourceWalletTracker?.connectSilent();
    _onAmountChanged();
    notify();
  }

  void updateDestinationAsset(BaseSwapAsset asset) {
    if (destinationAsset == asset) return;
    if (destinationAsset?.network != asset.network) {
      _updateDestinationAddress();
    }
    destinationAsset = asset;
    _cleanRoute();
    _status = SwapRouteStatus.success;
    _destinationAddressHint =
        "${SwapUtils.getFakeAddress(asset.network).substring(0, 16)}...";
    destinalWalletTracker?.dispose();
    _destinalWalletTracker = WalletTracker.instance(network: asset.network);
    _destinalWalletTracker?.addListener(
      (w) {
        _lock.synchronized(() {
          if (w == null || !w.status.isConnnet) return;
          final defaultAddress = w.selectedAddresses.firstOrNull?.addressStr;
          if (defaultAddress == null) return;
          _updateDestinationAddress(address: defaultAddress);
        });
      },
    );
    _destinalWalletTracker?.connectSilent();
    _onAmountChanged();
    notify();
  }

  SwapRouteWithBps _buildRoute(SwapRoute route) {
    SwapAmount? totalFee;
    final fees = route.fees
        .map((e) => e.token == null
            ? null
            : getTokenPrice(e.amount.amountString, e.token!))
        .whereType<SwapAmount>();
    if (fees.isNotEmpty && fees.length == route.fees.length) {
      totalFee = fees.fold<SwapAmount>(
          SwapAmount.fromBigInt(BigInt.zero, fees.first.decimals!),
          (p, c) => p += c);
    }
    final amoutOut =
        getTokenPrice(route.quote.amount.amountString, route.quote.sourceAsset);
    final amountIn = getTokenPrice(
        route.expectedAmount.amountString, route.quote.destinationAsset);
    RouteBpsPriceDetails? bps;
    if (amountIn != null && amoutOut != null) {
      SwapAmount change = amountIn - amoutOut;
      final p = (BigRational(change.amount) / BigRational(amountIn.amount)) *
          BigRational.from(100);
      final percentage = p.toDouble();
      bps = RouteBpsPriceDetails(
          amount: change,
          bpsPercentage: "${percentage.abs().toStringAsFixed(1)}%",
          minus: percentage.isNegative);
    }
    return SwapRouteWithBps(route: route, bps: bps, totalFee: totalFee);
  }

  APPSwapRoutes? _buildRoutes(List<SwapRoute> routes) {
    if (routes.isEmpty) return null;
    return APPSwapRoutes(routes.map(_buildRoute).toList());
  }

  Future<void> _createRoute(
      {required BaseSwapAsset source,
      required BaseSwapAsset destination,
      required String amount,
      String? sourceAddress,
      String? destinationAddress}) async {
    _cleanRoute();
    await _lock.synchronized(() async {
      final r = await MethodUtils.call(() async {
        _status = SwapRouteStatus.pending;
        notify();
        return await _api.findRoute(
          sourceAsset: source,
          destinationAsset: destination,
          amountIn: amount,
          sourceAddress: sourceAddress ?? _getSourceAddress(),
          destinationAddress: destinationAddress ?? _getDestinationAddress(),
        );
      }, cancelable: _cancelable);
      if (r.isCancel) return;
      if (r.hasError) {
        _status = SwapRouteStatus.failed;
        _errors = [RouteError(error: r.error!.tr)];
        // _errorMessage = r.error!.tr;
      } else {
        _currentRoute = _buildRoutes(
            r.result.map((e) => e.route).whereType<SwapRoute>().toList());
        _errors = r.result
            .where((e) => !e.hasRoute)
            .map((e) => RouteError(
                error: MethodResult.findErrorMessage(e.error!).tr,
                provider: e.provider))
            .toList();
        if (_currentRoute != null) {
          _status = SwapRouteStatus.success;
        } else {
          _status = SwapRouteStatus.failed;
          if (_errors.isEmpty) {
            _errors = [RouteError(error: "no_swap_route_found".tr)];
          }
        }
      }
      notify();
    });
  }

  Future<void> _onAmountChanged(
      {String? sourceAddress, String? destinationAddress}) async {
    final source = sourceAsset;
    final out = destinationAsset;

    final amount = MethodUtils.nullOnException(() =>
        SwapAmount.fromString(amountController.getText(), source!.decimal));
    if (source == null || out == null || amount == null) {
      _cleanRoute();
      notify();
      return;
    }

    _createRoute(
        source: source,
        destination: out,
        amount: amount.amountString,
        sourceAddress: sourceAddress,
        destinationAddress: destinationAddress);
  }

  Future<void> createSwapTransaction({
    required ONREVIEWTX onPage,
  }) async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    final route = currentRoute;

    if (route == null) return;
    _txError = null;
    _page = SwapPage.review;
    notify();
    await Future.delayed(const Duration(seconds: 5));
    final r = await _lock.synchronized(() async {
      return MethodUtils.call(
          () async => await _api.builSwapTransaction(
              sourceAddress: sourceAddress,
              destinationAddress: destinationAddress,
              swapRoute: route.route.route),
          delay: APPConst.animationDuraion);
    });
    if (r.hasError) {
      _txError = r.error!.tr;
      _page = SwapPage.swap;
      notify();
      return;
    }
    await onPage(r.result, route.route, _sourceWalletTracker);
    _page = SwapPage.swap;
    notify();
  }

  Future<void> initSwap() async {
    progressKey.progress();
    _disposeSwap();
    await _lock.synchronized(() async {
      if (appSetting.chainType.isMainnet) {
        _api = await SwapServiceApi.loadApi(DefaultSwapServiceApiParams(
            services:
                appSetting.swapProviders.map((e) => e.service).toSet().toList(),
            swapKitServiceProviders: appSetting.swapProviders
                .whereType<SwapKitSwapServiceProvider>()
                .toList()));
      } else {
        _api =
            await SwapServiceApi.loadApi(DefaultSwapServiceApiParams.testnet());
      }

      _api.getSourceAssets().then((e) {
        _sourceAssets = e;
        updateSourceAsset(_sourceAssets.values.first.first);
        updateDestinationAsset(_destinationAssets.values.first.last);
        progressKey.backToIdle();
        streamPrices();
      });
      amountController.addListener(_listenChangeAmount);
    });
  }

  void _disposeSwap() {
    amountController.removeListener(_listenChangeAmount);
    amountController.clear();
    sourceWalletTracker?.dispose();
    _sourceWalletTracker = null;
    destinalWalletTracker?.dispose();
    _destinalWalletTracker = null;
    _cleanRoute();
  }
}
