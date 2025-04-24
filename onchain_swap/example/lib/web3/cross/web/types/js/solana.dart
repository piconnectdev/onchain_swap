import 'dart:js_interop';
import 'package:on_chain/solana/solana.dart' show TransactionType;

import 'global.dart';
import 'wallet_standard.dart';

extension type SolanaSignAndSendTransactionOutput._(JSObject _)
    implements JSAny {
  external APPJSUint8Array get signature;
}

@JS()
extension type SolanaWalletAdapterSolanaSignTransactionFeature(JSAny _)
    implements JSAny {
  external JSPromise<JSAny> signTransaction(
      JSArray<JSSolanaSignTransactionParams> params);
  external JSArray<JSAny>? get supportedTransactionVersions;
  @JS("signTransaction")
  external JSFunction? get signTransaction_;
  TransactionType? getSupportVersion() {
    final dartVersions =
        supportedTransactionVersions?.toDart.map((e) => e.dartify()).toList();
    if (dartVersions == null) return null;
    if (dartVersions.contains(0) || dartVersions.contains('0')) {
      return TransactionType.v0;
    }
    if (dartVersions.contains(TransactionType.legacy.name)) {
      return TransactionType.legacy;
    }
    return null;
  }
}
@JS()
extension type SolanaSignTransactionOutput._(JSObject _) implements JSAny {
  external APPJSUint8Array get signedTransaction;
}
@JS()
extension type JSSolanaSignTransactionParams._(JSObject _) implements JSAny {
  external factory JSSolanaSignTransactionParams(
      {JSWalletStandardAccount? account,
      APPJSUint8Array? transaction,
      String? chain});
  external JSWalletStandardAccount get account;
  external APPJSUint8Array get transaction;
  external String? get chain;
}

@JS()
extension type SolanaWalletAdapterSolanaSignAndSendTransactionFeature(JSAny _)
    implements JSAny {
  external JSArray? get supportedTransactionVersions;
  external JSPromise<JSArray<SolanaSignAndSendTransactionOutput>>
      signAndSendTransaction(
          JSArray<JSSolanaSignTransactionParams> transactions);
}
