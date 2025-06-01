import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:onchain_swap_example/app/error/exception.dart';
import 'package:onchain_swap_example/app/utils/string.dart';
import 'package:on_chain_bridge/models/device/models/platform.dart';
import 'dart:async';

import 'auth.dart';

enum HTTPRequestType {
  get("GET"),
  post("POST");

  final String name;
  const HTTPRequestType(this.name);
  static HTTPRequestType fromName(String? name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () => throw AppExceptionConst.invalidData(
          messsage: "invalid http request type name"),
    );
  }
}

class HTTPWorkerMessage {
  final HTTPRequestType type;
  final Uri url;
  final Object? params;
  final Map<String, String>? headers;
  final Duration timeout;
  final HTTPResponseType responseType;
  final HTTPClientType clientType;
  final ProviderAuthenticated? authenticated;
  factory HTTPWorkerMessage.fromJson(Map<String, dynamic> json) {
    return HTTPWorkerMessage(
        type: HTTPRequestType.fromName(json["type"]),
        url: Uri.parse(json["url"]),
        params: json["params"],
        timeout: Duration(seconds: json["timeout"]),
        responseType: HTTPResponseType.fromName(json["responseType"]),
        clientType: HTTPClientType.fromName(json["clientType"]),
        authenticated: json["authenticated"] == null
            ? null
            : ProviderAuthenticated.deserialize(cborHex: json["authenticated"]),
        headers: Map<String, String>.from(json["headers"] ?? {}));
  }
  const HTTPWorkerMessage(
      {required this.type,
      required this.url,
      required this.params,
      required this.timeout,
      required this.responseType,
      required this.clientType,
      this.authenticated,
      this.headers});
  Map<String, dynamic> toJson() {
    return {
      "url": url.toString(),
      "type": type.name,
      "params": params,
      "headers": headers,
      "timeout": timeout.inSeconds,
      "responseType": responseType.name,
      "clientType": clientType.name,
      "authenticated": authenticated?.toCbor().toCborHex()
    };
  }
}

class HTTPWorkerRequest {
  final int id;
  final HTTPWorkerMessage message;
  const HTTPWorkerRequest({required this.id, required this.message});
  Map<String, dynamic> toJson() {
    return {"id": id, "message": message.toJson()};
  }

  factory HTTPWorkerRequest.fromJson(Map<String, dynamic> json) {
    return HTTPWorkerRequest(
        id: json["id"],
        message: HTTPWorkerMessage.fromJson((json["message"] as Map).cast()));
  }
}

abstract class HTTPWorkerResponse {
  final int id;
  abstract final HTTPCallerResponse response;
  bool get isSuccess => true;
  const HTTPWorkerResponse({required this.id});
  factory HTTPWorkerResponse.fromJs(Map<String, dynamic> json) {
    if (json.containsKey("response")) {
      return HTTPWorkerResponseSuccess(
          response: HTTPCallerResponse.fromJs(
              (json["response"] as Map).cast<String, dynamic>()),
          id: json["id"]);
    }
    return HTTPWorkerResponseError(message: json["message"], id: json["id"]);
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "response": response.toJson()};
  }
}

class HTTPWorkerResponseSuccess<T> extends HTTPWorkerResponse {
  @override
  final HTTPCallerResponse response;
  const HTTPWorkerResponseSuccess({required this.response, required super.id});
  @override
  Map<String, dynamic> toJson() {
    return {"id": id, "response": response.toJson()};
  }
}

class HTTPWorkerResponseError<T> extends HTTPWorkerResponse {
  @override
  bool get isSuccess => false;
  final String message;
  @override
  HTTPCallerResponse get response =>
      throw ApiProviderException(message: message);
  const HTTPWorkerResponseError({required this.message, required super.id});
  factory HTTPWorkerResponseError.fromJson(Map<String, dynamic> json) {
    return HTTPWorkerResponseError(id: json["id"], message: json["message"]);
  }
  @override
  Map<String, dynamic> toJson() {
    return {"id": id, "message": message};
  }
}

class HTTPWorkerMessageCompleter {
  final int id;
  HTTPWorkerMessageCompleter(this.id);
  final Completer<HTTPWorkerResponse> _messageCompleter = Completer();

  void complete(HTTPWorkerResponse message) {
    _messageCompleter.complete(message);
  }

  void error(AppException err) {
    _messageCompleter.completeError(err);
  }

  Future<HTTPWorkerResponse> getResult({Duration? timeout}) async {
    final result = await _messageCompleter.future
        .timeout(timeout ?? const Duration(seconds: 60));
    return result;
  }
}

enum HTTPResponseType {
  binary,
  string,
  json,
  map,
  listOfMap;

  static HTTPResponseType fromName(String? name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () => throw AppExceptionConst.invalidData(
          messsage: "invalid response type name"),
    );
  }
}

enum HTTPClientType {
  cached,
  single;

  static HTTPClientType fromName(String? name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () => throw AppExceptionConst.invalidData(
          messsage: "invalid client type name"),
    );
  }
}

typedef OnStreamReapose = void Function(
    int cumulativeBytesLoaded, int expectedTotalBytes);

class HTTPCallerResponse {
  final Object? result;
  final int statusCode;
  final HTTPResponseType responseType;

  HTTPCallerResponse copyWith(
      {Object? result, int? statusCode, HTTPResponseType? responseType}) {
    return HTTPCallerResponse(
        result: result ?? this.result,
        statusCode: statusCode ?? this.statusCode,
        responseType: responseType ?? this.responseType);
  }

  factory HTTPCallerResponse.fromJs(Map<String, dynamic> json) {
    final responseType = HTTPResponseType.fromName(json["responseType"]);
    final int status = json["statusCode"];
    return HTTPCallerResponse(
        result: isSuccessStatusCode(status)
            ? fromJsObject(json["result"], responseType)
            : json["result"],
        statusCode: status,
        responseType: responseType);
  }
  Map<String, dynamic> toJson() {
    return {
      "result": result,
      "statusCode": statusCode,
      "responseType": responseType.name
    };
  }

  static bool isSuccessStatusCode(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  static Object stringToJsonObject(String data, HTTPResponseType type) {
    switch (type) {
      case HTTPResponseType.json:
        return StringUtils.toJson(data);
      case HTTPResponseType.map:
        return StringUtils.toJson<Map<String, dynamic>>(data);
      case HTTPResponseType.listOfMap:
        return StringUtils.toJson<List>(data)
            .map((e) => (e as Map).cast<String, dynamic>())
            .toList();
      default:
        return data;
    }
  }

  static Object? fromJsObject(Object? fromJsObject, HTTPResponseType type) {
    if (fromJsObject == null) return null;
    switch (type) {
      case HTTPResponseType.binary:
        return (fromJsObject as List).cast<int>();
      default:
        return stringToJsonObject(fromJsObject as String, type);
    }
  }

  bool get isSuccess => isSuccessStatusCode(statusCode);

  T bodyAs<T>() {
    return result as T;
  }

  T successResult<T>() {
    throwIfError();
    return bodyAs<T>();
  }

  String? error() {
    if (isSuccess) return null;
    return result as String?;
  }

  void throwIfError() {
    if (isSuccess) return;
    final err = error();
    if (err?.isEmpty ?? true) {
      throw ApiProviderException(statusCode: statusCode);
    } else if (StrUtils.isHtml(err!)) {
      throw ApiProviderException(statusCode: statusCode);
    } else {
      throw ApiProviderException(statusCode: statusCode, message: err);
    }
  }

  const HTTPCallerResponse({
    required this.result,
    required this.statusCode,
    required this.responseType,
  });
  factory HTTPCallerResponse.parse(
      {required List<int> bodyBytes,
      required int statusCode,
      required HTTPResponseType type,
      required AppPlatform platform}) {
    if (!isSuccessStatusCode(statusCode)) {
      return HTTPCallerResponse(
          result: StringUtils.tryDecode(bodyBytes),
          statusCode: statusCode,
          responseType: type);
    }
    Object body;
    try {
      if (platform == AppPlatform.web && type != HTTPResponseType.binary) {
        body = StringUtils.decode(bodyBytes);
      } else {
        switch (type) {
          case HTTPResponseType.binary:
            body = bodyBytes;
            break;
          case HTTPResponseType.string:
            body = StringUtils.decode(bodyBytes);
            break;
          case HTTPResponseType.json:
            body = StringUtils.toJson(StringUtils.decode(bodyBytes));
            break;
          case HTTPResponseType.map:
            body = StringUtils.toJson<Map<String, dynamic>>(
                StringUtils.decode(bodyBytes));
            break;
          case HTTPResponseType.listOfMap:
            body = StringUtils.toJson<List>(StringUtils.decode(bodyBytes))
                .map((e) => (e as Map).cast<String, dynamic>())
                .toList();
            break;
        }
      }
      return HTTPCallerResponse(
          result: body, statusCode: statusCode, responseType: type);
    } on ApiProviderException {
      rethrow;
    } catch (e) {
      throw ApiProviderException(message: "invalid_request_type");
    }
  }
}

enum DigestAuthHeadersAlg {
  md5(name: "MD5"),
  md5Sess(name: "MD5-sess"),
  sha256(name: "SHA-256"),
  sha256Sess(name: "SHA-256-sess"),
  sha512(name: "SHA-512"),
  sha512Sess(name: "SHA-512-sess"),
  sha512256(name: "SHA-512-256"),
  sha512256Sess(name: "SHA-512-256-sess");

  bool get sessionBased => name.endsWith("sess");

  final String name;
  const DigestAuthHeadersAlg({required this.name});
  static DigestAuthHeadersAlg fromName(String? name) {
    if (name == null) return DigestAuthHeadersAlg.md5;
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw AppException("unsuported_digest_auth_algorithm"));
  }

  List<int> hashBytes(List<int> input) {
    return switch (this) {
      DigestAuthHeadersAlg.md5 ||
      DigestAuthHeadersAlg.md5Sess =>
        MD5.hash(input),
      DigestAuthHeadersAlg.sha256 ||
      DigestAuthHeadersAlg.sha256Sess =>
        SHA256.hash(input),
      DigestAuthHeadersAlg.sha512 ||
      DigestAuthHeadersAlg.sha512Sess =>
        SHA512.hash(input),
      DigestAuthHeadersAlg.sha512256 ||
      DigestAuthHeadersAlg.sha512256Sess =>
        SHA512256.hash(input),
    };
  }

  String hashString(String input) {
    return BytesUtils.toHexString(hashBytes(StringUtils.encode(input)));
  }
}

enum DigestAuthQop {
  auth(name: "auth"),
  authInt(name: "auth-int");

  final String name;
  const DigestAuthQop({required this.name});
  static DigestAuthQop fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw AppException("unsuported_digest_auth_qop"));
  }
}

class DigestAuthHeaders {
  final String nonce;
  final DigestAuthQop? qop;
  final String realm;
  final DigestAuthHeadersAlg algorithm;
  final String? opaque;
  const DigestAuthHeaders(
      {required this.nonce,
      this.qop,
      required this.realm,
      required this.algorithm,
      required this.opaque});
  factory DigestAuthHeaders.fromJson(Map<String, dynamic> json) {
    return DigestAuthHeaders(
        nonce: json["nonce"],
        qop: json["qop"] == null ? null : DigestAuthQop.fromName(json["qop"]),
        realm: json["realm"],
        algorithm: DigestAuthHeadersAlg.fromName(json["algorithm"]),
        opaque: json["opaque"]);
  }
}
