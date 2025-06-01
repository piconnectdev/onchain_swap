import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:onchain_swap_example/api/services/http/http.dart';

class TendermintHTTPService extends HTTPService
    implements TendermintServiceProvider {
  TendermintHTTPService(
      {required super.service,
      super.defaultTimeOut = const Duration(seconds: 30),
      super.requestTimeout});

  @override
  Future<TendermintServiceResponse<T>> doRequest<T>(
      TendermintRequestDetails params,
      {Duration? timeout}) async {
    return await serviceRequest<T>(params, allowStatus: [200]);
  }
}
