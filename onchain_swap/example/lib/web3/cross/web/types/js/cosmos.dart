// ignore_for_file: non_constant_identifier_names

import 'dart:js_interop';
import 'package:example/web3/cross/web/types/types.dart';

@JS()
extension type CosmosWalletAdapterStandardSignTransactionFeature(JSAny _)
    implements JSAny {
  external JSPromise<JSCosmosDirectSignResponse> signTransaction(
      JSCosmosSendOrSignTransactionParams params);
  @JS("signTransaction")
  external JSFunction? get signTransaction_;
}
@JS()
extension type JSCosmosSendOrSignTransactionParams._(JSAny _) implements JSAny {
  external APPJSUint8Array get transaction;
  external JSArray<JSString>? get signatures;
  external JSWalletStandardAccount? account;
  external factory JSCosmosSendOrSignTransactionParams(
      {APPJSUint8Array? transaction, JSWalletStandardAccount? account});
}
@JS()
extension type JSCosmosSignDoc(JSAny _) implements JSAny {
  external APPJSUint8Array? get bodyBytes;
  external set bodyBytes(APPJSUint8Array? _);

  external APPJSUint8Array? get authInfoBytes;
  external set authInfoBytes(APPJSUint8Array? _);
  external String? get chainId;
  external set chainId(String? _);
  external JSAny? get accountNumber;
  external set accountNumber(JSAny? _);
}
@JS()
extension type JSCosmosDirectSignResponse(JSAny _) implements JSAny {
  external JSCosmosSignDoc get signed;
  external set signed(JSCosmosSignDoc _);
  external JSCosmosStdSignature get signature;
  external set signature(JSCosmosStdSignature _);
}
@JS()
extension type JSCosmosPubKey(JSAny _) implements JSAny {
  external String get type;
  external String get value;
}
@JS()
extension type JSCosmosStdSignature(JSAny _) implements JSAny {
  external JSCosmosPubKey get pub_key;
  external String get signature;
  external set pub_key(JSCosmosPubKey _);
  external set signature(String _);
}
