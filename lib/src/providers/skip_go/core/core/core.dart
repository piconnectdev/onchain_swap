import 'package:blockchain_utils/service/service.dart';
import 'package:blockchain_utils/utils/string/string.dart';
import 'package:on_chain_swap/src/providers/skip_go/constatns/constants.dart';

abstract class SkipGoApiRequest<RESULT, RESPONSE>
    extends BaseServiceRequest<RESULT, RESPONSE, SkipGoApiRequestDetails> {
  const SkipGoApiRequest();
  abstract final String method;
  @override
  RequestServiceType get requestType;
}

abstract class SkipGoApiPostRequest<RESULT, RESPONSE>
    extends SkipGoApiRequest<RESULT, RESPONSE> {
  const SkipGoApiPostRequest();
  @override
  RequestServiceType get requestType => RequestServiceType.post;
  Map<String, dynamic> body();

  @override
  SkipGoApiRequestDetails buildRequest(int requestID) {
    return SkipGoApiRequestDetails(
        requestID: requestID,
        pathParams: method,
        headers: ServiceConst.defaultPostHeaders,
        type: requestType,
        jsonBody: body());
  }
}

abstract class SkipGoApiGetRequest<RESULT, RESPONSE>
    extends SkipGoApiRequest<RESULT, RESPONSE> {
  const SkipGoApiGetRequest();
  @override
  RequestServiceType get requestType => RequestServiceType.get;
  Map<String, dynamic> get queryParameters => {};
  Map<String, String>? get headers => null;

  @override
  SkipGoApiRequestDetails buildRequest(int requestID) {
    final Map<String, dynamic> query = {};
    for (final i in queryParameters.entries) {
      final key = i.key;
      final value = i.value;
      if (value == null) continue;
      if (value is List) {
        if (value.isEmpty) continue;
        query[key] = value.map((e) => e.toString()).toList();
      } else {
        query[key] = value.toString();
      }
    }
    final uri = Uri(path: method, queryParameters: query);
    return SkipGoApiRequestDetails(
        requestID: requestID,
        pathParams: uri.normalizePath().toString(),
        headers: headers ?? const {},
        type: requestType);
  }
}

class SkipGoApiRequestDetails extends BaseServiceRequestParams {
  const SkipGoApiRequestDetails({
    required super.requestID,
    required this.pathParams,
    required super.headers,
    required super.type,
    super.successStatusCodes = SkipGoApiConstants.successStatusCodes,
    super.errorStatusCodes = SkipGoApiConstants.errorStatusCodes,
    this.jsonBody,
  });

  SkipGoApiRequestDetails copyWith({
    int? requestID,
    String? pathParams,
    RequestServiceType? type,
    Map<String, String>? headers,
    Map<String, dynamic>? jsonBody,
  }) {
    return SkipGoApiRequestDetails(
        pathParams: pathParams ?? this.pathParams,
        jsonBody: jsonBody ?? this.jsonBody,
        headers: headers ?? this.headers,
        requestID: requestID ?? this.requestID,
        type: type ?? this.type);
  }

  /// URL path parameters
  final String pathParams;

  @override
  List<int>? body() {
    if (jsonBody != null) {
      return StringUtils.encode(StringUtils.fromJson(jsonBody!));
    }
    return null;
  }

  final Map<String, dynamic>? jsonBody;

  @override
  Map<String, dynamic> toJson() {
    return {
      'pahtParameters': pathParams,
      'body': jsonBody,
      'type': type.name,
    };
  }

  @override
  Uri toUri(String uri) {
    if (uri.endsWith('/')) {
      uri = uri.substring(0, uri.length - 1);
    }
    final finalUrl = '$uri$pathParams';
    return Uri.parse(finalUrl);
  }
}
