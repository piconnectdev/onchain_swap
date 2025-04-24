import 'dart:async';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:example/api/services/socket/core/socket_provider.dart';
import 'package:example/app/synchronized/basic_lock.dart';
import 'package:example/app/utils/method.dart';
import 'package:example/app/websocket/core/core.dart';

class WebSocketService extends BaseSocketService {
  WebSocketService({required super.service});

  final _lock = SynchronizedLock();
  PlatformWebScoket? _socket;
  SocketStatus _status = SocketStatus.disconnect;
  StreamSubscription<String>? _subscription;
  @override
  bool get isConnected => _status == SocketStatus.connect;

  final Map<int, SocketRequestCompleter> _requests = {};
  void _add(List<int> message) {
    _socket?.sink(message);
  }

  void _onClose() {
    _status = SocketStatus.disconnect;
    _subscription?.cancel().catchError((e) {});
    _socket?.close();
    _subscription = null;
    _socket = null;
  }

  @override
  void disposeService() => _onClose();

  Map<String, dynamic>? onMessge(String event) {
    final Map<String, dynamic> decode = StringUtils.toJson(event);
    if (decode.containsKey("id")) {
      final int id = int.parse(decode["id"]!.toString());
      final request = _requests.remove(id);
      request?.completer.complete(decode);
      if (request != null) {
        return null;
      }
    }
    return decode;
  }

  @override
  Future<void> connect() async {
    await _lock.synchronized(() async {
      try {
        if (_status != SocketStatus.disconnect) return;
        final result = await MethodUtils.call(() async {
          final socket = await PlatformWebScoket.connect(service.url);
          return socket;
        });
        if (result.hasResult) {
          _status = SocketStatus.connect;
          _socket = result.result;
          _subscription =
              _socket?.stream.cast<String>().listen(onMessge, onDone: _onClose);
        } else {
          _status = SocketStatus.disconnect;

          throw result.exception!;
        }
      } catch (e) {
        rethrow;
      }
    });
  }

  Future<Map<String, dynamic>> addMessage(
      SocketRequestCompleter message, Duration timeout) async {
    try {
      return providerCaller(() async {
        _requests[message.id] = message;
        _add(message.params);
        final result = await message.completer.future.timeout(timeout);
        return result;
      }, message);
    } finally {
      _requests.remove(message.id);
    }
  }

  @override
  ServiceProtocol get protocol => ServiceProtocol.websocket;
}
