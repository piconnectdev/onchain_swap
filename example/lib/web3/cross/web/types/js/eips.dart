import 'dart:js_interop';
import 'package:onchain_swap_example/web3/cross/web/types/types.dart';
import 'package:onchain_bridge/web/api/core/js.dart';

class _EIP1193Consts {
  static const Map<String, dynamic> knownWalletNmes = {
    'isMetaMask': 'MetaMask',
    'isCoinbaseWallet': 'Coinbase Wallet',
    'isRabby': 'Rabby',
    'isFrame': 'Frame',
    'isTally': 'Tally',
    'isTrust': 'Trust Wallet',
    'isBraveWallet': 'Brave Wallet',
  };
}

@JS('ethereum')
external JSEIP1193? get ethereum;

@JS()
extension type JSEIP1193RequestParams._(JSAny _) implements JSAny {
  external String method;
  external JSArray<JSAny>? params;
  external factory JSEIP1193RequestParams(
      {required String method, JSArray<JSAny>? params});
}
@JS("Error")
extension type JSError._(JSAny _) implements JSAny {
  external factory JSError({String? message});
  external String? get message;
}

@JS()
extension type JSEIP1193(JSAny _) implements JSAny {
  external JSPromise<T> request<T extends JSAny>(JSEIP1193RequestParams params);
  external String? get selectedAddress;
  external String? get name;
  external String? get icon;
  String? getName() {
    if (name != null) return name;
    final keys = JSOBJ.keys_(this) ?? [];
    for (final i in keys) {
      if (_EIP1193Consts.knownWalletNmes.containsKey(i)) {
        return _EIP1193Consts.knownWalletNmes[i];
      }
    }
    final isNames =
        keys.where((e) => e.startsWith("is") && e.length > 2).toList();
    if (isNames.length != 1) return null;
    return isNames[0].substring(2);
  }

  @JS("request")
  external JSFunction? get request_;
  @JS("on")
  external JSFunction? get on_;
  @JS("on")
  external void on(String name, JSFunction callBack);
  @JS("removeListener")
  external JSFunction? get removeListener_;
  @JS("removeListener")
  external void removeListener(String name, JSFunction callBack);

  bool isEIP1193() {
    return request_ != null && on_ != null;
  }
}
@JS()
extension type EIP6963ProviderInfo._(JSObject _) implements JSAny {
  external String? get uuid;
  external String? get name;
  external String? get icon;
  external String? get rdns;
}
@JS()
extension type JSEIP6963(JSAny _) implements JSAny {
  external EIP6963ProviderInfo? get info;
  external JSEIP1193? get provider;
  bool isEIP6963() {
    return info != null && provider != null && provider!.isEIP1193();
  }

  String? getName() {
    if (info?.name != null) return info?.name;
    return provider?.getName();
  }
}
@JS()
extension type JSEthereumTransactionParams._(JSObject o) implements JSAny {
  external factory JSEthereumTransactionParams({
    String? nonce,
    String? gasLimit,
    String? maxPriorityFeePerGas,
    String? maxFeePerGas,
    String? gasPrice,
    String? from,
    String? to,
    String? value,
    String? data,
    String? chainId,
    String? type,
    JSArray<JSEthereumTransactionAccessListParams>? accessList,
  });
  external String? get nonce;
  external set nonce(String? value);

  external String? get gasLimit;
  external set gasLimit(String? value);

  external String? get maxPriorityFeePerGas;
  external set maxPriorityFeePerGas(String? value);

  external String? get maxFeePerGas;
  external set maxFeePerGas(String? value);

  external String? get gasPrice;
  external set gasPrice(String? value);

  external String? get from;
  external set from(String? value);

  external String? get to;
  external set to(String? value);

  external String? get value;
  external set value(String? value);

  external String? get data;
  external set data(String? value);

  external String? get chainId;
  external set chainId(String? value);

  external String? get type;
  external set type(String? value);

  external JSArray<JSEthereumTransactionAccessListParams>? get accessList;
  external set accessList(
      JSArray<JSEthereumTransactionAccessListParams>? value);
}
@JS()
extension type JSEthereumTransactionAccessListParams._(JSObject o)
    implements JSAny {
  external factory JSEthereumTransactionAccessListParams(
      {String? address, JSArray<JSString>? storageKeys});
  external String? get address;
  external set address(String? value);

  external JSArray<JSString>? get storageKeys;
  external set storageKeys(JSArray<JSString>? value);
}
@JS()
extension type EthereumWalletStandardTransactionParams._(JSObject o)
    implements JSAny {
  external factory EthereumWalletStandardTransactionParams(
      {JSWalletStandardAccount? account,
      JSEthereumTransactionParams? transaction});
  external JSWalletStandardAccount? get account;
  external JSEthereumTransactionParams? get transaction;
}
@JS()
extension type EthereumWalletAdapterSendTransactionFeature(JSAny _)
    implements JSAny {
  external JSPromise<JSEthereumSendTransactionResponse> sendTransaction(
      EthereumWalletStandardTransactionParams params);
  @JS("sendTransaction")
  external JSFunction? get sendTransaction_;
}
@JS()
extension type JSEthereumSendTransactionResponse._(JSObject o)
    implements JSAny {
  external String get txId;
}
