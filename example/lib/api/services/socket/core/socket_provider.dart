import 'dart:async';
import 'package:blockchain_utils/exception/exceptions.dart';
import 'package:onchain_swap_example/api/services/core/service.dart';
import 'package:onchain_swap_example/app/error/exception/http.dart';
import 'package:onchain_swap_example/app/error/exception/app.dart';
import 'package:on_chain_bridge/models/device/models/platform.dart';

class SocketRequestCompleter {
  SocketRequestCompleter(this.params, this.id);
  final Completer completer = Completer();
  final List<int> params;
  final int id;
}

enum SocketStatus { connect, disconnect, pending }

enum ServiceProtocol {
  http("HTTP", 0),
  ssl("SSL", 1),
  tcp("TCP", 2),
  websocket("WebSocket", 3);

  const ServiceProtocol(this.value, this.id);
  final String value;
  final int id;

  List<AppPlatform> get platforms {
    switch (this) {
      case ServiceProtocol.http:
      case ServiceProtocol.websocket:
        return AppPlatform.values;
      default:
        return [
          AppPlatform.android,
          AppPlatform.windows,
          AppPlatform.ios,
          AppPlatform.macos
        ];
    }
  }

  bool supportOnThisPlatform(AppPlatform platform) {
    return platforms.contains(platform);
  }

  static ServiceProtocol fromID(int id, {ServiceProtocol? orElese}) {
    return ServiceProtocol.values.firstWhere((element) => element.id == id,
        orElse: orElese == null ? null : () => orElese);
  }

  static bool isValid(String url) {
    final parse = Uri.tryParse(url);
    if (parse == null) return false;
    return parse.scheme.startsWith('http') || parse.scheme.startsWith('ws');
  }

  static ServiceProtocol fromURI(String url) {
    final lower = url.toLowerCase();
    if (lower.startsWith("http")) {
      return ServiceProtocol.http;
    } else if (lower.startsWith("ws")) {
      return ServiceProtocol.websocket;
    } else {
      throw const AppException(
          "Invalid URL. The ServiceProtocol.fromURI function is designed to work exclusively with http and websocket URIs.");
    }
  }

  static List<ServiceProtocol> get supportedProtocols {
    return [
      ServiceProtocol.ssl,
      ServiceProtocol.tcp,
      ServiceProtocol.websocket
    ];
  }

  @override
  String toString() {
    return value;
  }
}

abstract class BaseSocketService extends APIService {
  BaseSocketService({required super.service});
  Future<void> connect();
  ServiceProtocol get protocol;
  bool get isConnected;
  void disposeService();

  Future<Map<String, dynamic>> providerCaller(
      Future<Map<String, dynamic>> Function() t,
      SocketRequestCompleter param) async {
    return await _onException(t);
  }

  Future<Map<String, dynamic>> _onException(
      Future<Map<String, dynamic>> Function() t) async {
    try {
      await connect().timeout(const Duration(seconds: 30));
      if (!isConnected) {
        throw ApiProviderException(message: "node_connection_error");
      }
      final response = await t();
      return response;
    } on ApiProviderException {
      rethrow;
    } on RPCError catch (e) {
      throw ApiProviderException(
          message: e.message, statusCode: e.errorCode, code: e.errorCode);
    } on TimeoutException {
      throw ApiProviderException(message: "api_http_timeout_error");
    } on ArgumentError catch (e) {
      throw ApiProviderException(message: e.message.toString());
    } catch (e) {
      throw ApiProviderException(message: "api_unknown_error");
    }
  }
}
