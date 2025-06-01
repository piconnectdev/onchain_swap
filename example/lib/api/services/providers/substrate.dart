import 'package:blockchain_utils/service/models/params.dart';
import 'package:onchain_swap_example/api/services/http/http.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class SubstrateHTTPService extends HTTPService with SubstrateServiceProvider {
  SubstrateHTTPService(
      {required super.service,
      super.defaultTimeOut = const Duration(seconds: 30),
      super.requestTimeout});

  @override
  Future<BaseServiceResponse<T>> doRequest<T>(SubstrateRequestDetails params,
      {Duration? timeout}) async {
    return await serviceRequest<T>(params,
        uri: params.toUri(service.url), allowStatus: [200], timeout: timeout);
  }
}
