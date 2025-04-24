import 'package:example/api/services/http/http.dart';
import 'package:onchain_swap/onchain_swap.dart';

class SwapKitHTTPService extends HTTPService implements SwapKitServiceProvider {
  SwapKitHTTPService(
      {required super.service,
      super.defaultTimeOut = const Duration(minutes: 1),
      super.requestTimeout = const Duration(milliseconds: 100)});

  @override
  Future<SwapKitServiceResponse<T>> doRequest<T>(SwapKitRequestDetails params,
      {Duration? timeout}) async {
    return await serviceRequest<T>(params, allowStatus: []);
  }
}
