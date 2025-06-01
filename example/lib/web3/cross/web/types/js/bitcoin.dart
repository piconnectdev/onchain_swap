import 'dart:js_interop';

import 'package:onchain_swap_example/web3/cross/web/types/types.dart';

@JS()
extension type JSWalletStandardBitcoinSignTransactionFeature(JSAny _)
    implements JSAny {
  external JSPromise<JSBitcoinSignTransactionResponse> signTransaction(
      JSBitcoinSignTransactionParams params);
  @JS("signTransaction")
  external JSFunction? get signTransaction_;
}
extension type JSBitcoinSignTransactionParams._(JSAny _) implements JSAny {
  external factory JSBitcoinSignTransactionParams(
      {JSArray<JSWalletStandardAccount>? accounts, String? psbt});
}
extension type JSBitcoinSignTransactionResponse(JSAny _) implements JSAny {
  external String get psbt;
}
