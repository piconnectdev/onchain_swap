import 'package:blockchain_utils/exception/exceptions.dart';
import 'package:blockchain_utils/service/service.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:onchain_swap/src/providers/swap_kit/core/core/core.dart';
import 'package:onchain_swap/src/providers/swap_kit/service/service.dart';

class SwapKitProvider implements BaseProvider<SwapKitRequestDetails> {
  final SwapKitServiceProvider rpc;

  SwapKitProvider(this.rpc);

  static SERVICERESPONSE _findError<SERVICERESPONSE>(
      {required BaseServiceResponse<SERVICERESPONSE> response,
      required SwapKitRequestDetails params}) {
    if (response.type == ServiceResponseType.error) {
      final Map<String, dynamic>? error =
          StringUtils.tryToJson(response.cast<ServiceErrorResponse>().error);
      final String message = error?["message"] ??
          ServiceConst.httpErrorMessages[response.statusCode] ??
          ServiceConst.defaultError;
      throw RPCError(
          message: message,
          details: {
            "statusCode": response.statusCode,
            "details": error?["details"]
          },
          errorCode: IntUtils.tryParse(error?["code"]));
    }
    final SERVICERESPONSE r = response.getResult(params);

    return ServiceProviderUtils.parseResponse(object: r, params: params);
  }

  int _id = 0;

  @override
  Future<RESULT> request<RESULT, SERVICERESPONSE>(
      BaseServiceRequest<RESULT, SERVICERESPONSE, SwapKitRequestDetails>
          request,
      {Duration? timeout}) async {
    final r = await requestDynamic(request, timeout: timeout);
    return request.onResonse(r);
  }

  @override
  Future<SERVICERESPONSE> requestDynamic<RESULT, SERVICERESPONSE>(
      BaseServiceRequest<RESULT, SERVICERESPONSE, SwapKitRequestDetails>
          request,
      {Duration? timeout}) async {
    final params = request.buildRequest(_id++);
    final response =
        await rpc.doRequest<SERVICERESPONSE>(params, timeout: timeout);
    return _findError(params: params, response: response);
  }
}
