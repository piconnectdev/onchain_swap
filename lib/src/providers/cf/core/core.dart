import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:on_chain_swap/src/exception/exception.dart';
import 'package:on_chain_swap/src/providers/cf/constants/constants.dart';
import 'package:on_chain_swap/src/providers/cf/utils/utils.dart';

enum CfRequestType { backend, rpc, batchTrcp }

abstract class CfRequestParam<RESULT, RESPONSE>
    extends BaseServiceRequest<RESULT, RESPONSE, CfRequestDetails> {
  CfRequestType get cfRequestType => CfRequestType.backend;
  const CfRequestParam();
}

abstract class CfBackendRequestParam<RESULT, RESPONSE>
    extends CfRequestParam<RESULT, RESPONSE> {
  const CfBackendRequestParam();
  @override
  CfRequestType get cfRequestType => CfRequestType.backend;
  abstract final String method;
  List<String> get pathParameters => [];
  Map<String, dynamic>? get queryParameters => null;

  @override
  RESULT onResonse(RESPONSE result) {
    return result as RESULT;
  }

  @override
  RequestServiceType get requestType => RequestServiceType.get;
  @override
  CfRequestDetails buildRequest(int v) {
    final pathParams = ChainFlipProviderUtils.extractParams(method);
    if (pathParams.length != pathParameters.length) {
      throw DartOnChainSwapPluginException("Invalid Path Parameters.",
          details: {
            "pathParams": pathParameters,
            "ExceptedPathParametersLength": pathParams.length
          });
    }
    String params = method;
    for (int i = 0; i < pathParams.length; i++) {
      params = params.replaceFirst(pathParams[i], pathParameters[i]);
    }
    final queryParams = Map<String, dynamic>.from(queryParameters ?? {});
    if (queryParams.isNotEmpty) {
      params = Uri(path: params, queryParameters: queryParams)
          .normalizePath()
          .toString();
    }
    return CfRequestDetails(
      requestID: v,
      pathParams: params,
      type: requestType,
      cfRequestType: cfRequestType,
    );
  }
}

abstract class CfRPCRequestParam<RESULT, RESPONSE>
    extends CfRequestParam<RESULT, RESPONSE> {
  const CfRPCRequestParam();

  @override
  CfRequestType get cfRequestType => CfRequestType.rpc;
  abstract final String method;
  List<dynamic> get params => [];
  final Map<String, String>? headers = null;
  @override
  RequestServiceType get requestType => RequestServiceType.post;
  @override
  CfRequestDetails buildRequest(int requestID) {
    return CfRequestDetails(
      requestID: requestID,
      headers: headers ?? ServiceConst.defaultPostHeaders,
      pathParams: method,
      type: RequestServiceType.post,
      bodyJson: ServiceProviderUtils.buildJsonRPCParams(
          requestId: requestID, method: method, params: params),
      cfRequestType: cfRequestType,
    );
  }
}

abstract class CfTRPCRequest<RESULT, RESPONSE>
    extends CfRequestParam<RESULT, RESPONSE> {
  const CfTRPCRequest();
  abstract final String method;

  @override
  CfRequestType get cfRequestType => CfRequestType.batchTrcp;
  Map<String, dynamic> get params => {};
  Map<String, dynamic>? get queryParameters => null;
  final Map<String, String>? headers = null;
  @override
  RequestServiceType get requestType => RequestServiceType.post;
  @override
  CfRequestDetails buildRequest(int requestID) {
    String pathParameters = "/trpc/$method";
    final queryParams = Map<String, dynamic>.from(queryParameters ?? {});
    if (queryParams.isNotEmpty) {
      pathParameters = Uri(path: pathParameters, queryParameters: queryParams)
          .normalizePath()
          .toString();
    }
    return CfRequestDetails(
        requestID: requestID,
        headers: headers ?? ServiceConst.defaultPostHeaders,
        pathParams: pathParameters,
        type: RequestServiceType.post,
        bodyJson: params,
        cfRequestType: cfRequestType,
        errorStatusCodes: CfProviderConst.trpcErrorStatusCodes);
  }
}

class CfRequestDetails extends BaseServiceRequestParams {
  final CfRequestType cfRequestType;
  const CfRequestDetails(
      {this.pathParams,
      super.headers = const {},
      super.type = RequestServiceType.get,
      this.bodyJson,
      required super.requestID,
      required this.cfRequestType,
      super.errorStatusCodes});

  CfRequestDetails copyWith(
      {int? requestID,
      String? pathParams,
      RequestServiceType? type,
      Map<String, String>? headers,
      Map<String, dynamic>? bodyJson,
      CfRequestType? cfRequestType}) {
    return CfRequestDetails(
      requestID: requestID ?? this.requestID,
      pathParams: pathParams ?? this.pathParams,
      type: type ?? this.type,
      headers: headers ?? this.headers,
      bodyJson: bodyJson ?? this.bodyJson,
      cfRequestType: cfRequestType ?? this.cfRequestType,
    );
  }

  final Map<String, dynamic>? bodyJson;

  /// URL path parameters
  final String? pathParams;

  @override
  List<int>? body() {
    if (bodyJson == null) return null;
    return StringUtils.encode(StringUtils.fromJson(bodyJson!));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "pathParameters": pathParams,
      "body": bodyJson,
      "type": type.name,
      "cfRequestType": cfRequestType.name
    };
  }

  @override
  Uri toUri(String uri, {String? brokerUrl}) {
    if (pathParams == "broker_requestSwapDepositAddress") {
      if (brokerUrl == null) {
        throw UnimplementedError(
            "brokerUrl must be set for broker request. `broker_requestSwapDepositAddress`");
      }
      uri = brokerUrl;
    }
    if (cfRequestType == CfRequestType.rpc) {
      return Uri.parse("$uri/");
    }
    String url = uri;
    if (url.endsWith("/")) {
      url = url.substring(0, url.length - 1);
    }
    return Uri.parse("$url$pathParams");
  }
}
