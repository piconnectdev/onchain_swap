import 'dart:async';
import 'package:onchain_swap_example/app/error/exception.dart';
import 'package:on_chain_swap/onchain_swap.dart';
import 'package:onchain_swap_example/app/http/impl/impl.dart';
import 'package:onchain_swap_example/app/http/models/models.dart';
import 'package:onchain_swap_example/app/live_listener/live.dart';
import 'package:onchain_swap_example/app/models/models/setting.dart';
import 'package:onchain_swap_example/app/synchronized/basic_lock.dart'
    show SynchronizedLock;
import 'package:onchain_swap_example/app/utils/method.dart';
import 'package:onchain_swap_example/future/state_managment/state_managment.dart';
import 'coingecko.dart';
import 'currency.dart';
import 'utils.dart';

mixin LiveCurrencies on StateController, HttpImpl {
  final _lock = SynchronizedLock();
  final _requestLock = SynchronizedLock();
  late final Live<Currency> _currency = Live<Currency>(appSetting.currency);
  Currency get currencyToken => _currency.value;
  CoingeckoPriceHandler _currenciesPrice = CoingeckoPriceHandler({});
  StreamSubscription? _streamPrices;
  final Cancelable _cancelStream = Cancelable();
  List<BaseSwapAsset> get allAssets;
  APPSetting get appSetting;

  Future<List<String>> _getCoinList() async {
    final json = await httpGet<List<Map<String, dynamic>>>(
        CoinGeckoUtils.coinGeckoCoinListURL,
        responseType: HTTPResponseType.listOfMap);
    return json.result
        .map((e) => CoingeckoCoin.fromJson(e))
        .map((e) => e.id)
        .toList();
  }

  Future<T> _callCoinGecko<T>(Future<T> Function() t,
      {bool firstCall = false}) async {
    return await _requestLock.synchronized(() async {
      while (true) {
        if (!firstCall) await Future.delayed(const Duration(seconds: 15));
        try {
          return await t();
        } on ApiProviderException catch (e) {
          if (e.statusCode == 429) {
            firstCall = false;
            continue;
          }
          rethrow;
        }
      }
    });
  }

  Future<CoingeckoPriceHandler> _getCoinPrices(List<String> coins) async {
    final url = CoinGeckoUtils.toCoingeckoPriceUri(
        Currency.toApiCall(), coins.join(","));
    final json = await httpGet<Map<String, dynamic>>(url,
        responseType: HTTPResponseType.map);
    return CoingeckoPriceHandler.fromJson(json.result);
  }

  SwapAmount? getTokenPrice(String amount, BaseSwapAsset token) {
    return _currenciesPrice.getPrice(
        baseCurrency: currencyToken, token: token, amount: amount);
  }

  void _onUpdatePrices(CoingeckoPriceHandler result) {
    _currenciesPrice.merge(result);
    _currency.notify();
  }

  List<String>? _ids;
  void streamPrices() async {
    if (_streamPrices != null) return;
    await _lock.synchronized(() async {
      _streamPrices = MethodUtils.prediocCaller<void>(() async {
        final result = await MethodUtils.call(() async {
          if (_ids == null) {
            final coinIds = await _callCoinGecko(_getCoinList, firstCall: true);
            _ids = allAssets
                .where((e) => coinIds.contains(e.coingeckoId))
                .map((e) => e.coingeckoId)
                .whereType<String>()
                .toList();
            _currenciesPrice =
                CoingeckoPriceHandler({for (final i in _ids!) i: null});
          }
          while (true) {
            final remindIds = _currenciesPrice.getIds();
            if (remindIds.isEmpty) break;
            final r = await _callCoinGecko(
                () => _getCoinPrices(remindIds.take(400).toList()));
            _onUpdatePrices(r);
          }
        });
        return result;
      },
              waitOnSuccess: const Duration(minutes: 10),
              waitOnError: const Duration(minutes: 1),
              canclable: _cancelStream)
          .listen((e) {});
    });
  }

  void _disposeSteam() async {
    await _lock.synchronized(() {
      MethodUtils.nullOnException(() {
        _streamPrices?.cancel().catchError((e) => null);
        _streamPrices = null;
        _cancelStream.cancel();
      });
    });
  }

  void changeCurrency(Currency? currency) {
    if (currency == null) return;
    _currenciesPrice.clearCache();
    _currency.value = currency;
  }

  @override
  void close() {
    super.close();
    _disposeSteam();
  }
}
