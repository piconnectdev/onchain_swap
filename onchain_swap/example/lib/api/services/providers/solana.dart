import 'package:blockchain_utils/service/service.dart';
import 'package:example/api/services/http/http.dart';
import 'package:on_chain/solana/solana.dart';

class SolanaHTTPService extends HTTPService implements SolanaServiceProvider {
  SolanaHTTPService(
      {required super.service,
      super.defaultTimeOut = const Duration(seconds: 30),
      super.requestTimeout});

  @override
  Future<BaseServiceResponse<T>> doRequest<T>(SolanaRequestDetails params,
      {Duration? timeout}) async {
    return await serviceRequest<T>(params,
        uri: params.toUri(service.url), allowStatus: [200], timeout: timeout);
  }
}
