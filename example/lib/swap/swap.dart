import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:onchain_swap_example/app/live_listener/live.dart';
import 'package:onchain_swap/onchain_swap.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:onchain_swap_example/api/services/services.dart';
import 'package:onchain_swap_example/api/services/socket/core/socket_provider.dart';
import 'package:onchain_swap_example/app/http/models/auth.dart';

class DefaultSwapServiceApiParams extends BaseSwapServiceApiParams {
  final bool testnet;
  final List<SwapKitSwapServiceProvider>? swapKitServiceProviders;
  DefaultSwapServiceApiParams.testnet()
      : testnet = true,
        swapKitServiceProviders = null,
        super([SwapServiceType.chainFlip]);
  DefaultSwapServiceApiParams({
    List<SwapServiceType> services = const [
      SwapServiceType.chainFlip,
      SwapServiceType.maya,
      SwapServiceType.thor,
      SwapServiceType.swapKit
    ],
    List<SwapKitSwapServiceProvider>? swapKitServiceProviders,
  })  : swapKitServiceProviders = swapKitServiceProviders?.immutable,
        testnet = false,
        super(services);

  /// 1339942095353
  /// 1275848805863
  @override
  Future<MayaSwapService> loadMayaService() async {
    return MayaSwapService(
        provider: ThorNodeProvider(ThorNodeHTTPService(
            service: ServiceInfo(
                url: "https://mayanode.mayachain.info/mayachain",
                protocol: ServiceProtocol.http))));
  }

  @override
  Future<SkipGoSwapService> loadSkipGoService() async {
    return SkipGoSwapService(
        provider: SkipGoApiProvider(SkipGoHTTPService(
            service: ServiceInfo(
                url: "https://api.skip.build", protocol: ServiceProtocol.http),
            defaultTimeOut: const Duration(minutes: 1))));
  }

  @override
  Future<SwapKitSwapService> loadSwapKitService() async {
    return SwapKitSwapService(
        providers: swapKitServiceProviders ?? [],
        provider: SwapKitProvider(SwapKitHTTPService(
            service: ServiceInfo(
                url: "https://api.swapkit.dev",
                protocol: ServiceProtocol.http,
                authenticated: BasicProviderAuthenticated(
                    type: ProviderAuthType.header,
                    key: "x-api-key",
                    value: "9e1a8dce-8e2d-4cad-9d09-9430df70743c")))));
  }

  @override
  Future<ThorSwapService> loadThorService() async {
    return ThorSwapService(
        provider: ThorNodeProvider(ThorNodeHTTPService(
            service: ServiceInfo(
                protocol: ServiceProtocol.http,
                url: "https://thornode.ninerealms.com/thorchain"))));
  }

  @override
  Future<CfSwapService> loadChainFlipService() async {
    if (testnet) {
      return CfSwapService(
          chainType: ChainType.testnet,
          provider: CfProvider(ChainFlipHTTPService(
              service: ServiceInfo(
                  url: 'https://chainflip-swap-perseverance.chainflip.io/',
                  protocol: ServiceProtocol.http))));
    }
    return CfSwapService(
        provider: CfProvider(ChainFlipHTTPService(
            service: ServiceInfo(
                url: 'https://chainflip-swap.chainflip.io/',
                protocol: ServiceProtocol.http))));
  }
}

class RouteBpsPriceDetails {
  final SwapAmount amount;
  final String bpsPercentage;
  final bool minus;
  const RouteBpsPriceDetails(
      {required this.amount, required this.bpsPercentage, required this.minus});
}

class SwapRouteWithBps {
  final SwapRoute route;
  final RouteBpsPriceDetails? bps;
  final SwapAmount? totalFee;
  SwapServiceProvider get provider => route.provider;
  const SwapRouteWithBps(
      {required this.route, required this.bps, required this.totalFee});
}

enum SwapSortingMode {
  speed,
  fee;

  bool get isSpeed => this == speed;
}

class APPSwapRoutes {
  List<SwapRouteWithBps> _routes;
  Live<SwapRouteWithBps> _route;
  List<SwapRouteWithBps> get routes => _routes;
  SwapRouteWithBps get route => _route.value;
  SwapServiceProvider get provider => route.provider;
  SwapAmount get expectAmout => route.route.expectedAmount;
  double _tolerance;
  double get tolerance => _tolerance;
  bool get hasMultipleRoute => _routes.length > 1;
  SwapSortingMode _sorting = SwapSortingMode.speed;
  SwapSortingMode get mode => _sorting;
  bool get supportTolerance => route.route.supportTolerance;
  double _maxTolerance;
  double get maxTolerance => _maxTolerance;

  void toggleSorting() {
    final routes = _routes.clone();
    _sorting = SwapSortingMode.values.firstWhere((e) => e != _sorting);
    if (_sorting.isSpeed) {
      routes
          .sort((a, b) => b.route.estimateTime.compareTo(a.route.estimateTime));
    } else {
      routes.sort((a, b) => a.route.expectedAmount.amount
          .compareTo(b.route.expectedAmount.amount));
    }
    _routes = routes.immutable;
    _route.notify();
  }

  APPSwapRoutes._(
      {required List<SwapRouteWithBps> routes, required SwapRouteWithBps route})
      : _routes = routes.immutable,
        _route = Live(route),
        _tolerance = route.route.tolerance,
        _maxTolerance =
            IntUtils.max(50, route.route.tolerance.ceil()).toDouble();
  factory APPSwapRoutes(List<SwapRouteWithBps> routes) {
    routes.sort((a, b) => b.route.estimateTime.compareTo(a.route.estimateTime));
    return APPSwapRoutes._(routes: routes, route: routes.last);
  }
  int get index => _routes.indexOf(route);

  void updateTolerance(double tolerance) {
    final route = this.route;
    final routes = _routes.clone();
    final index = routes.indexOf(route);
    if (index.isNegative) return;
    final updateRoute = route.route.updateTolerance(tolerance);
    final newRoute = SwapRouteWithBps(
        route: updateRoute, bps: route.bps, totalFee: route.totalFee);
    routes[index] = newRoute;
    _routes = routes.immutable;
    _tolerance = newRoute.route.tolerance;
    _maxTolerance =
        IntUtils.max(50, newRoute.route.tolerance.ceil()).toDouble();
    _route.value = newRoute;
  }

  void onChangeRoute(int index) {
    assert(index < _routes.length, "Invalid route index.");
    if (index >= _routes.length) return;
    final route = routes.elementAt(index);
    _tolerance = route.route.tolerance;
    _maxTolerance = IntUtils.max(50, route.route.tolerance.ceil()).toDouble();
    _route.value = route;
  }
}

class RouteError {
  final SwapServiceProvider? provider;
  final String error;
  const RouteError({this.provider, required this.error});
}
