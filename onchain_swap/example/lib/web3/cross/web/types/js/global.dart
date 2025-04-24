import 'dart:js_interop';

@JS("Uint8Array")
extension type APPJSUint8Array(JSAny _) implements JSAny {
  external static APPJSUint8Array from(JSAny? v);
  external APPJSUint8Array slice();
  factory APPJSUint8Array.fromList(List<int> bytes) {
    return APPJSUint8Array.from(bytes.jsify());
  }
  List<int> toListInt() {
    return (dartify() as List?)?.cast() ?? [];
  }
}
