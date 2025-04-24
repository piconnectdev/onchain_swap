import 'package:example/api/services/http/http.dart';
import 'package:onchain_swap/onchain_swap.dart';

class ChainFlipHTTPService extends HTTPService implements CfServiceProvider {
  ChainFlipHTTPService(
      {required super.service,
      super.defaultTimeOut = const Duration(seconds: 30),
      super.requestTimeout});

  @override
  Future<CfServiceResponse<T>> doRequest<T>(CfRequestDetails params,
      {Duration? timeout}) async {
    return await serviceRequest<T>(params, allowStatus: [200]);
  }
}
