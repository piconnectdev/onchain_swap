import 'package:blockchain_utils/service/models/params.dart';
import 'package:onchain_swap_example/api/services/http/http.dart';
import 'package:on_chain/on_chain.dart';

class EthereumHTTPService extends HTTPService
    implements EthereumServiceProvider {
  EthereumHTTPService({
    required super.service,
    super.defaultTimeOut = const Duration(seconds: 30),
    super.requestTimeout,
  });

  @override
  Future<BaseServiceResponse<T>> doRequest<T>(EthereumRequestDetails params,
      {Duration? timeout}) async {
    return await serviceRequest<T>(params,
        uri: params.toUri(service.url), allowStatus: [200], timeout: timeout);
  }
}
