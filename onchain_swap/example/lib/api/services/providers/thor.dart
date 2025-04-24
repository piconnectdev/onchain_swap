import 'package:blockchain_utils/service/service.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:example/api/services/http/http.dart';

class ThorNodeHTTPService extends HTTPService
    implements ThorNodeServiceProvider {
  ThorNodeHTTPService(
      {required super.service,
      super.defaultTimeOut = const Duration(seconds: 30),
      super.requestTimeout});

  @override
  Future<BaseServiceResponse<T>> doRequest<T>(ThorNodeRequestDetails params,
      {Duration? timeout}) async {
    return await serviceRequest<T>(params, allowStatus: [200]);
  }
}
