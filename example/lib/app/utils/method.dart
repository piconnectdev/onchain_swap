import 'dart:async';
import 'dart:io' show HttpException, SocketException;
import 'package:blockchain_utils/exception/exceptions.dart';
import 'package:onchain_swap_example/app/error/exception.dart';

class MethodUtils {
  static Future<void> wait(
      {Duration duration = const Duration(milliseconds: 1000)}) async {
    return await Future.delayed(duration);
  }

  static Future<T> after<T>(Future<T> Function() t,
      {Duration duration = Duration.zero}) async {
    return await Future.delayed(duration, t);
  }

  static Future<MethodResult<T>> call<T>(Future<T> Function() t,
      {final Cancelable? cancelable,
      final Duration? delay,
      final Duration? timeout,
      final Duration? waitAtError}) async {
    try {
      if (delay != null) {
        await Future.delayed(delay);
      }
      Future<T> r;
      if (cancelable == null) {
        r = t();
      } else {
        final Completer<T> completer = Completer<T>();
        cancelable.setup(() {
          return completer;
        });
        cancelable.success(t);
        r = completer.future;
      }
      if (timeout != null) {
        r = r.timeout(timeout);
      }
      final result = await r;
      return MethodResult.success(result);
    } catch (e, stackTrace) {
      if (waitAtError != null) {
        await wait(duration: waitAtError);
      }
      return MethodResult.error(e, stackTrace);
    }
  }

  static Stream<T> prediocCaller<T>(Future<MethodResult<T>> Function() t,
      {Duration waitOnError = const Duration(seconds: 1),
      Duration waitOnSuccess = const Duration(seconds: 10),
      required Cancelable canclable,
      bool closeOnSuccess = false}) async* {
    bool run = true;
    while (run) {
      final Completer<MethodResult<T>> completer = Completer();
      canclable.setup(() => completer);
      canclable.success(() => t());
      final result = await call(() async {
        final r = await completer.future;
        return r.result;
      });
      if (result.hasResult) {
        yield result.result;
        if (closeOnSuccess) {
          run = false;
          continue;
        }
        final Completer<void> waitCompleter = Completer();
        canclable.setup(() => waitCompleter);
        final onErrorWait =
            await call(() async => waitCompleter.future.timeout(waitOnSuccess));
        if (onErrorWait.isCancel) {
          run = false;
          continue;
        }
        canclable.dispose();
      } else {
        if (result.isCancel) {
          run = false;
          continue;
        }
        final Completer<void> waitCompleter = Completer();
        canclable.setup(() => waitCompleter);
        final onErrorWait =
            await call(() async => waitCompleter.future.timeout(waitOnError));
        if (onErrorWait.isCancel) {
          run = false;
          continue;
        }
        canclable.dispose();
      }
    }
  }

  static T? nullOnException<T>(T? Function() t, {T? defaultValue}) {
    try {
      return t();
    } catch (e) {
      return defaultValue;
    }
  }
}

class MethodResult<T> {
  factory MethodResult.success(T result) {
    return MethodResult._succsess(result);
  }
  factory MethodResult.error(Object exception, Object? trace) {
    final errorMessage = findErrorMessage(exception);
    return MethodResult._error(
      error: errorMessage,
      trace: trace,
      exception: exception,
    );
  }
  MethodResult._error(
      {required Object this.exception,
      required this.error,
      required this.trace});
  MethodResult._succsess(this._result)
      : exception = null,
        trace = null,
        error = null;
  late final T _result;
  static String findErrorMessage(Object exception) {
    if (exception is AppException) {
      return exception.message;
    }
    if (exception is BlockchainUtilsException) {
      return exception.message;
    }
    if (exception is FormatException) return "format_exception";
    if (exception is TimeoutException) return "timeout_exception";
    if (exception is SocketException) return "socket_exception";
    if (exception is HttpException) return "http_exception";
    if (exception is RangeError) return "range_error";
    if (exception is ArgumentError) return "argument_error";
    if (exception is StateError) return "state_error";
    if (exception is UnimplementedError) return "unimplemented_error";
    if (exception is UnsupportedError) return "unsupported_error";
    if (exception is AssertionError) return "assertion_error";
    if (exception is TypeError) return "type_error";
    return exception.toString();
  }

  final Object? exception;
  final Object? trace;
  final String? error;

  bool get hasError => exception != null;
  bool get hasResult => exception == null;
  bool get isCancel => exception is CancelableExption;
  bool errorISA<E extends Object>() {
    return exception is E;
  }

  T get result {
    if (hasError) {
      throw exception!;
    }
    return _result;
  }

  T? get resultOrNull {
    if (hasError) {
      return null;
    }
    return _result;
  }

  @override
  String toString() {
    if (hasError) {
      return "Error $error";
    }
    return "Success $result";
  }
}

typedef CompleterResult = Completer Function();

class Cancelable<T> {
  CompleterResult? _setup;
  void cancel([Object? exception]) {
    final completer = _setup?.call();
    if (completer?.isCompleted ?? true) return;
    _setup = null;
    MethodUtils.nullOnException(
        () => completer?.completeError(exception ?? const CancelableExption()));
  }

  void success(Future<T> Function() func) async {
    final completer = _setup?.call();
    final r = func();
    if (completer?.isCompleted ?? true) return;
    try {
      final result = await r;
      completer?.complete(result);
    } catch (e, stackTrace) {
      MethodUtils.nullOnException(
          () => completer?.completeError(e, stackTrace));
    } finally {
      _setup = null;
    }
  }

  void setup(CompleterResult setup) {
    assert(_setup == null, "please first complete or cancel");
    _setup = setup;
  }

  void dispose() {
    _setup = null;
  }
}

extension QuickFunction<T> on Function {
  T? nullOnException({List<dynamic>? positionalArguments}) =>
      MethodUtils.nullOnException(
          () => Function.apply(this, positionalArguments));

  T valueOrException(Object exception, {List<dynamic>? positionalArguments}) {
    final result = MethodUtils.nullOnException(
        () => Function.apply(this, positionalArguments));
    if (result == null) throw exception;
    return result as T;
  }
}
