import 'dart:async';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:onchain_swap/src/providers/cf/core/core.dart';
import 'package:onchain_swap/src/providers/cf/service/service.dart';

class CfProvider implements BaseProvider<CfRequestDetails> {
  final CfServiceProvider rpc;

  CfProvider(this.rpc);

  static SERVICERESPONSE _findError<SERVICERESPONSE>(
      {required BaseServiceResponse response,
      required CfRequestDetails params}) {
    if (response.type == ServiceResponseType.error) {
      final err = response.cast<ServiceErrorResponse>();
      final Map<String, dynamic>? error = StringUtils.tryToJson(err.error);
      if (params.cfRequestType == CfRequestType.batchTrcp) {
        Map<String, dynamic>? errorData =
            StringUtils.tryToJson(error?["error"]);
        if (errorData?.containsKey("json") ?? false) {
          errorData = StringUtils.tryToJson(errorData!["json"]);
        }
        final String? message = errorData?["message"]?.toString();
        final int? code = IntUtils.tryParse(errorData?["code"]);
        final Map<String, dynamic>? data =
            StringUtils.tryToJson(errorData?["data"]);
        throw RPCError(
            message: message ??
                ServiceConst.httpErrorMessages[err.statusCode] ??
                ServiceConst.defaultError,
            errorCode: code,
            details: data,
            request: params.toJson());
      }
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
    final r = response.getResult(params);
    if (params.type == RequestServiceType.get ||
        params.cfRequestType == CfRequestType.batchTrcp) {
      return ServiceProviderUtils.parseResponse(object: r, params: params);
    }
    final jsonRpcResponse = r as Map<String, dynamic>;
    final Map<String, dynamic>? error =
        StringUtils.tryToJson(jsonRpcResponse["error"]);
    if (error != null) {
      throw RPCError(
          message: error["message"]?.toString() ?? ServiceConst.defaultError,
          errorCode: IntUtils.tryParse(error["code"]),
          details: error);
    }
    return ServiceProviderUtils.parseResponse(
        object: jsonRpcResponse["result"], params: params);
  }

  int _id = 0;

  @override
  Future<RESULT> request<RESULT, SERVICERESPONSE>(
      BaseServiceRequest<RESULT, SERVICERESPONSE, CfRequestDetails> request,
      {Duration? timeout}) async {
    final r = await requestDynamic(request, timeout: timeout);
    return request.onResonse(r);
  }

  @override
  Future<SERVICERESPONSE> requestDynamic<RESULT, SERVICERESPONSE>(
      BaseServiceRequest<RESULT, SERVICERESPONSE, CfRequestDetails> request,
      {Duration? timeout}) async {
    final params = request.buildRequest(_id++);
    if (params.type == RequestServiceType.get ||
        params.cfRequestType == CfRequestType.batchTrcp) {
      final response =
          await rpc.doRequest<SERVICERESPONSE>(params, timeout: timeout);
      return _findError(params: params, response: response);
    }
    final response =
        await rpc.doRequest<Map<String, dynamic>>(params, timeout: timeout);
    return _findError(params: params, response: response);
  }
}
