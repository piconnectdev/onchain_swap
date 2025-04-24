import 'dart:async';
import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/service/models/params.dart';
import 'package:example/api/services/electrum/services/electrum_service.dart';
import 'package:example/api/services/socket/core/socket_provider.dart';
import 'package:example/api/services/socket/protocols/websocket.dart';

class ElectrumWebsocketService extends WebSocketService
    implements ElectrumService {
  ElectrumWebsocketService(
      {required super.service,
      this.defaultRequestTimeOut = const Duration(seconds: 30)});
  final Duration defaultRequestTimeOut;

  @override
  Future<BaseServiceResponse<T>> doRequest<T>(ElectrumRequestDetails params,
      {Duration? timeout}) async {
    final SocketRequestCompleter message =
        SocketRequestCompleter(params.body()!, params.requestID);
    final r = await addMessage(message, timeout ?? defaultRequestTimeOut);
    return params.toResponse(r);
  }
}
