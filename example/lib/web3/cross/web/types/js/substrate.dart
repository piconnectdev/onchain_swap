import 'dart:js_interop';

@JS()
extension type SubstrateWalletAdapterSubstrateSignTransactionFeature(JSAny _)
    implements JSAny {
  external JSPromise<JSSubstrateTxResponse> signTransaction(
      JSSubstrateTransaction params);
  @JS("signTransaction")
  external JSFunction? get signTransaction_;
}
@JS()
extension type JSSubstrateTransaction._(JSObject _) implements JSAny {
  external factory JSSubstrateTransaction({
    String? address,
    String? assetId,
    String? blockHash,
    String? blockNumber,
    String? era,
    String? genesisHash,
    String? metadataHash,
    String? method,
    int? mode,
    String? nonce,
    String? specVersion,
    String? tip,
    String? transactionVersion,
    JSArray<JSString>? signedExtensions,
    int? version,
    bool? withSignedTransaction,
  });
}
extension type JSSubstrateTxResponse._(JSObject _) implements JSAny {
  external factory JSSubstrateTxResponse(
      {int id, String signature, String? signedTransaction});
  external String get signature;
}
