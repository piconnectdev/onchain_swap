import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:onchain_swap/onchain_swap.dart';
import 'package:example/app/price/utils.dart';
import 'currency.dart';

class CoingeckoCoin {
  final String id;
  final String name;
  final String symbol;
  const CoingeckoCoin(
      {required this.id, required this.name, required this.symbol});
  factory CoingeckoCoin.fromJson(Map<String, dynamic> json) {
    return CoingeckoCoin(
        id: json["id"], name: json["name"], symbol: json["symbol"]);
  }
}

class CoingeckoCoinInfo {
  final String id;
  final Map<Currency, dynamic> prices;
  final DateTime expire;

  bool isExpired() {
    return expire.isBefore(DateTime.now());
  }

  CoingeckoCoinInfo({required this.id, required this.prices})
      : expire = DateTime.now().add(const Duration(minutes: 10));
  factory CoingeckoCoinInfo.fromJson(Map<String, dynamic> json, String id) {
    final Map<Currency, dynamic> prices = {};
    for (final i in json.entries) {
      final currency = Currency.fromName(i.key);
      if (currency == null) continue;
      prices[currency] = i.value.toString();
    }
    return CoingeckoCoinInfo(id: id, prices: prices);
  }

  BigRational? getPrice(Currency currency) {
    if (!prices.containsKey(currency)) return null;
    final val = prices[currency]!;
    if (val is String) {
      prices[currency] = BigRational.parseDecimal(val);
    }
    return prices[currency];
  }
}

class CoingeckoPriceHandler {
  Map<String, CoingeckoCoinInfo?> _coins;
  CoingeckoPriceHandler(this._coins);
  factory CoingeckoPriceHandler.fromJson(Map<String, dynamic> json) {
    return CoingeckoPriceHandler(json.map(
        (key, value) => MapEntry(key, CoingeckoCoinInfo.fromJson(value, key))));
  }
  final Map<String, SwapAmount> _caches = {};
  SwapAmount? getPrice(
      {required Currency baseCurrency,
      required BaseSwapAsset token,
      required String amount}) {
    if (token.symbol.toUpperCase() == baseCurrency.name) {
      return null;
    }
    final String? apiId = token.coingeckoId;
    final name = "${baseCurrency.name}_${apiId}_$amount";
    final BigRational? basePrice = _coins[apiId]?.getPrice(baseCurrency);

    if (basePrice == null) return null;
    final BigRational? aPrice = BigRational.tryParseDecimaal(amount);
    if (aPrice == null) return null;
    _caches[name] ??= _getPrice(
        basePrice: basePrice,
        token: token,
        amount: aPrice,
        baseCurrency: baseCurrency);

    return _caches[name];
  }

  SwapAmount _getPrice(
      {required BigRational basePrice,
      required BaseSwapAsset token,
      required BigRational amount,
      required Currency baseCurrency}) {
    final val = PriceUtils.decodePrice(
        (basePrice * amount).toDecimal(), token.decimal,
        validateDecimal: false);
    final encode = SwapUtils.encodePrice(val, token.decimal, amoutDecimal: 4);
    return SwapAmount.fromString(encode, baseCurrency.decimal);
  }

  void addCoin(CoingeckoCoinInfo newCoin) {
    _coins[newCoin.id] = newCoin;
  }

  void clearCache() {
    _caches.clear();
  }

  CoingeckoCoinInfo? getCoin(String id) {
    return _coins[id];
  }

  List<String> getIds() {
    return _coins.keys.where((k) => _coins[k]?.isExpired() ?? true).toList();
  }

  void merge(CoingeckoPriceHandler other) {
    _coins.addAll(other._coins);
  }
}
