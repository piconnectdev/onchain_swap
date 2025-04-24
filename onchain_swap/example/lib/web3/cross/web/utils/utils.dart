import 'dart:js_interop';

class JSWalletUtils {
  static List<JSAny> toList<T extends JSAny>(JSAny obj) {
    try {
      List<JSAny?> messages = [];
      if (obj.isA<JSArray>()) {
        messages = (obj as JSArray<JSAny?>).toDart;
      } else {
        messages.add(obj);
      }
      return messages.whereType<JSAny>().toList();
    } catch (e) {
      return [];
    }
  }
}
