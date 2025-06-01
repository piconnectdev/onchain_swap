import 'dart:js_interop';

import 'package:onchain_swap_example/web3/cross/web/types/js/global.dart';
import 'package:onchain_bridge/web/api/core/js.dart';
import 'package:onchain_bridge/web/api/window/window.dart';

import 'bitcoin.dart';
import 'cosmos.dart';
import 'eips.dart';
import 'solana.dart';
import 'substrate.dart';

@JS()
extension type JSSolanaWalletStandardConnect<
    ADDRESS extends JSWalletStandardAccount>._(JSObject _) implements JSAny {
  external JSArray<ADDRESS>? get accounts;
  List<ADDRESS> get accounts_ => accounts?.toDart ?? [];
}

@JS()
extension type JSWalletStandardAccount._(JSObject _) implements JSAny {
  external String get address;
  external JSAny? get publicKey;
  external JSArray<JSString>? get chains;
  external JSArray<JSString> get features;
  external String? get icon;
  external String? get label;
  external String? get name;

  bool isForNetwork(String network) {
    final chains = chains_;
    final identifier = "$network:";
    return chains.any((e) => e.startsWith(identifier));
  }

  bool isForChain(String identifier) {
    final chains = chains_;
    return chains.any((e) => e == identifier);
  }

  List<String> get chains_ =>
      chains?.toDart.map((e) => e.toDart).toList() ?? [];
}
@JS()
extension type JSWalletStandardBitcoinAccount._(JSObject _)
    implements JSWalletStandardAccount {
  external String? get type;
  external String? get witnessScript;
  external String? get redeemScript;
  external APPJSUint8Array? get publicKey;
}
extension type JSWalletStandardSubstrateAccount._(JSObject _)
    implements JSWalletStandardAccount {
  external String? get genesisHash;
}
extension type JSWalletStandardCosmosAccount._(JSObject _)
    implements JSWalletStandardAccount {
  external String? get algo;
  external APPJSUint8Array? get publicKey;
}

extension type JSWalletStandardConnectFeature._(JSObject _) implements JSAny {
  @JS("connect")
  external JSPromise<JSSolanaWalletStandardConnect<T>>
      connect<T extends JSWalletStandardAccount>();
}

extension type JSWalletStandardEvents._(JSObject _) implements JSAny {
  @JS("on")
  external JSFunction? on(JSString type, JSFunction callBack);
  @JS("on")
  external JSFunction? get on_;
}

extension type JSWalletStandardChangeEvents<
    ACCOUNT extends JSWalletStandardAccount>._(JSObject _) implements JSAny {
  external JSArray<JSString>? get chains;
  external JSArray<ACCOUNT>? get accounts;
  List<ACCOUNT>? get accounts_ => accounts?.toDart;
}
@JS()
extension type JSWalletStandardFeatures._(JSObject _) implements JSAny {
  // @JS("standard:connect")
  // external JSWalletStandardConnectFeature standardConnect;
  // @JS("standard:events")
  // external JSWalletStandardEvents? events;
  // @JS("substrate:signTransaction")
  // external SubstrateWalletAdapterSubstrateSignTransactionFeature?
  //     get substrateSignTransaction;
  // @JS("solana:signAndSendTransaction")
  // external SolanaWalletAdapterSolanaSignAndSendTransactionFeature?
  //     get solanaSignAndSendTransaction;
  // @JS("solana:signTransaction")
  // external SolanaWalletAdapterSolanaSignTransactionFeature?
  //     get solanaSignTransaction;
  // @JS("ethereum:sendTransaction")
  // external EthereumWalletAdapterSendTransactionFeature? ethereumSendTransaction;
  // @JS("cosmos:signTransaction")
  // external CosmosWalletAdapterStandardSignTransactionFeature?
  //     cosmosSignTransaction;
  JSWalletStandardConnectFeature? get standardConnect =>
      variableAs<JSWalletStandardConnectFeature>("standard:connect",
          properties: ["connect"]);
  JSWalletStandardEvents? get events =>
      variableAs<JSWalletStandardEvents>("standard:events", properties: ["on"]);
  SubstrateWalletAdapterSubstrateSignTransactionFeature?
      get substrateSignTransaction =>
          variableAs<SubstrateWalletAdapterSubstrateSignTransactionFeature>(
              "substrate:signTransaction",
              properties: ["signTransaction"]);
  SolanaWalletAdapterSolanaSignAndSendTransactionFeature?
      get solanaSignAndSendTransaction =>
          variableAs<SolanaWalletAdapterSolanaSignAndSendTransactionFeature>(
              "solana:signAndSendTransaction",
              properties: ["signAndSendTransaction"]);
  SolanaWalletAdapterSolanaSignTransactionFeature? get solanaSignTransaction =>
      variableAs<SolanaWalletAdapterSolanaSignTransactionFeature>(
          "solana:signTransaction",
          properties: ['signTransaction']);
  EthereumWalletAdapterSendTransactionFeature? get ethereumSendTransaction =>
      variableAs<EthereumWalletAdapterSendTransactionFeature>(
          "ethereum:sendTransaction",
          properties: ['sendTransaction']);

  CosmosWalletAdapterStandardSignTransactionFeature?
      get cosmosSignTransaction =>
          variableAs<CosmosWalletAdapterStandardSignTransactionFeature>(
              "cosmos:signTransaction",
              properties: ['signTransaction']);
  JSWalletStandardBitcoinSignTransactionFeature? get bitcoinSignTransaction =>
      variableAs<JSWalletStandardBitcoinSignTransactionFeature>(
          "bitcoin:signTransaction",
          properties: ['signTransaction']);

  // @JS("bitcoin:signTransaction")
  // external JSWalletStandardBitcoinSignTransactionFeature?
  //     bitcoinSignTransaction;

  // bool hasSupport(String feature) {
  //   final keys = Reflect.ownKeys_(this);
  //   if (keys.isEmpty) return false;
  //   return keys.contains(feature);
  // }
}

@JS()
extension type JSWalletStandard<ADDR extends JSWalletStandardAccount>(JSAny _)
    implements JSAny {
  external JSArray<JSString>? get chains;
  external JSWalletStandardFeatures? get features;
  external JSArray<ADDR>? get accounts;
  List<ADDR>? get accounts_ => accounts?.toDart;
  external String? get name;
  external String? get icon;
  external bool? get isMRT;
  bool isWalletStandard() {
    return features.isDefinedAndNotNull &&
        chains.isDefinedAndNotNull &&
        accounts.isDefinedAndNotNull &&
        name != null;
  }

  List<String> get chains_ =>
      chains?.toDart.map((e) => e.toDart).toList() ?? [];
  bool hasSuppurtChain(String chainIdentifier) {
    final chains = chains_;
    return chains.contains(chainIdentifier);
  }

  bool hasSupportNetwork(String network) {
    final chains = chains_;
    final identifier = "$network:";
    return chains.any((e) => e.startsWith(identifier));
  }

  String? getName() {
    return name;
  }

  bool get isMrtWallet {
    return getName() == 'MRT' || (isMRT == true);
  }
}
@JS()
extension type JSWalletStandardRegister(JSAny _) implements JSAny {
  external JSPromise<JSSolanaWalletStandardConnect> connect();
  external String? get name;
  external String? get icon;
}
@JS()
extension type JSWalletStandardAppIsReadyEvent(JSAny _) implements JSAny {}

extension QuickJS on JSAny {
  T? variableAs<T extends JSAny>(String key,
      {List<String> properties = const []}) {
    final keys = Reflect.ownKeys_(this);
    if (!keys.contains(key)) return null;
    final obj = Reflect.get(this, key.toJS, null);
    return JSOBJ.as(object: obj, keys: properties);
  }
}
