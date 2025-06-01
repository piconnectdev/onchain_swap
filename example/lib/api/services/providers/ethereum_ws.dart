import 'package:onchain_swap_example/api/services/socket/core/socket_provider.dart';
import 'package:onchain_swap_example/api/services/socket/protocols/websocket.dart';
import 'package:on_chain/on_chain.dart';

// class _EthereumWebsocketServiceConst {
//   static const String subscriptionMethodName = "eth_subscription";
//   static const String params = "params";
//   static const String method = "method";
// }

class EthereumWebsocketService extends WebSocketService
    implements EthereumServiceProvider {
  EthereumWebsocketService(
      {required super.service,
      this.defaultTimeOut = const Duration(seconds: 30)});
  // final List<ONETHSubsribe> _listeners = [];

  // void addSubscriptionListener(ONETHSubsribe listener) {
  //   _listeners.add(listener);
  // }

  // void removeSubscriptionListener(ONETHSubsribe listener) {
  //   _listeners.remove(listener);
  // }

  // void _emitListeners(EthereumSubscribeResult result) {
  //   for (final i in [..._listeners]) {
  //     MethodUtils.nullOnException(() => i(result));
  //   }
  // }

  @override
  Map<String, dynamic>? onMessge(String event) {
    final message = super.onMessge(event);
    // if (message != null &&
    //     message[_EthereumWebsocketServiceConst.method] ==
    //         _EthereumWebsocketServiceConst.subscriptionMethodName) {
    //   final result = MethodUtils.nullOnException(() {
    //     return EthereumSubscribeResult.fromJson(
    //         message[_EthereumWebsocketServiceConst.params]);
    //   });
    //   if (result != null) {
    //     _emitListeners(result);
    //   }
    // }
    return message;
  }

  final Duration defaultTimeOut;

  @override
  Future<EthereumServiceResponse<T>> doRequest<T>(EthereumRequestDetails params,
      {Duration? timeout}) async {
    final SocketRequestCompleter message =
        SocketRequestCompleter(params.body()!, params.requestID);
    final r = await addMessage(message, timeout ?? defaultTimeOut);
    return params.toResponse(r);
  }
}
