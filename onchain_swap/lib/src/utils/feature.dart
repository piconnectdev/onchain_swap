import 'dart:async';

class FutureUtils {
  static Stream<T> futuresToStream<T>(List<Future<T>> futures) {
    StreamController<T> controller = StreamController<T>();
    Future.wait(futures.map((future) async {
      try {
        T result = await future;
        controller.add(result);
      } catch (e) {
        controller.addError(e);
      }
    })).then((e) => controller.close());
    return controller.stream;
  }
}
