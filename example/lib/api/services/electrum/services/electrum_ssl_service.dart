import 'dart:async';
import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/service/models/params.dart';
import 'package:onchain_swap_example/api/services/socket/core/socket_provider.dart';
import 'package:onchain_swap_example/api/services/socket/protocols/ssl.dart';
import 'electrum_service.dart';

class ElectrumSSLSocketService extends SSLService implements ElectrumService {
  ElectrumSSLSocketService({
    required super.service,
    this.defaultRequestTimeOut = const Duration(seconds: 30),
  });
  final Duration defaultRequestTimeOut;

  @override
  Future<BaseServiceResponse<T>> doRequest<T>(ElectrumRequestDetails params,
      {Duration? timeout}) async {
    final SocketRequestCompleter message =
        SocketRequestCompleter(params.body()!, params.requestID);
    final r = await post(message, timeout ?? defaultRequestTimeOut);
    return params.toResponse(r);
  }
}
