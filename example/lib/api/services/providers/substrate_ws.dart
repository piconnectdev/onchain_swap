import 'package:blockchain_utils/service/models/params.dart';
import 'package:onchain_swap_example/api/services/socket/core/socket_provider.dart';
import 'package:onchain_swap_example/api/services/socket/protocols/websocket.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class SubstrateWebsocketService extends WebSocketService
    with SubstrateServiceProvider {
  SubstrateWebsocketService(
      {required super.service,
      this.defaultTimeOut = const Duration(seconds: 30)});

  final Duration defaultTimeOut;

  @override
  Future<BaseServiceResponse<T>> doRequest<T>(SubstrateRequestDetails params,
      {Duration? timeout}) async {
    final SocketRequestCompleter message =
        SocketRequestCompleter(params.body()!, params.requestID);
    final r = await addMessage(message, timeout ?? defaultTimeOut);
    return params.toResponse(r);
  }
}
