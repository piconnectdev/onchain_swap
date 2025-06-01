import 'dart:async';
import 'package:blockchain_utils/service/service.dart';
import 'package:onchain_swap_example/api/services/core/service.dart';
import 'package:onchain_swap_example/api/services/types/types.dart';
import 'package:onchain_swap_example/app/error/exception/http.dart';
import 'package:onchain_swap_example/app/http/http.dart';
import 'package:onchain_swap_example/app/synchronized/basic_lock.dart';
import 'package:http/http.dart' as http;

abstract class HTTPService extends APIService {
  final _lock = SynchronizedLock();
  final Duration defaultTimeOut;
  final Duration? requestTimeout;
  HTTPService(
      {required this.defaultTimeOut,
      required this.requestTimeout,
      required super.service});
  Future<BaseServiceResponse<T>> _onServiceException<T>(
      Future<HTTPCallerResponse> Function() t,
      {List<int> allowStatus = const [200]}) async {
    try {
      final response = await t();
      if (allowStatus.isNotEmpty &&
          !allowStatus.contains(response.statusCode)) {
        throw ApiProviderException(
            statusCode: response.statusCode, message: response.result);
      }
      return _readServiceResponse<T>(response);
    } on http.ClientException catch (e) {
      throw ApiProviderException(message: e.toString());
    } on ApiProviderException {
      rethrow;
    } on TimeoutException {
      throw ApiProviderException(
          message: "api_http_timeout_error",
          code: ApiProviderExceptionConst.timeoutStatucCode);
    } on FormatException {
      throw ApiProviderException(message: "invalid_json_response");
    } on ArgumentError catch (e) {
      throw ApiProviderException(message: e.message.toString());
    } catch (e) {
      throw ApiProviderException(message: "api_unknown_error");
    }
  }

  BaseServiceResponse<T> _readServiceResponse<T>(HTTPCallerResponse response) {
    try {
      if (response.isSuccess) {
        return ServiceSuccessRespose(
            response: response.bodyAs<T>(), statusCode: response.statusCode);
      }
      return ServiceErrorResponse(
          error: response.bodyAs<String?>(), statusCode: response.statusCode);
    } catch (e) {
      throw ApiProviderException(message: "invalid_request_type");
    }
  }

  HTTPResponseType _detectTemplateType<T>({HTTPResponseType? responseType}) {
    if (responseType != null) return responseType;
    if (dynamic is T) return HTTPResponseType.json;
    if (<dynamic>[] is T) return HTTPResponseType.json;
    if (<String, dynamic>{} is T) return HTTPResponseType.map;
    if (<Map<String, dynamic>>[] is T) return HTTPResponseType.listOfMap;
    if (<int>[] is T) return HTTPResponseType.binary;
    switch (T) {
      case const (String):
        return HTTPResponseType.string;
      default:
        return HTTPResponseType.json;
    }
  }

  Future<BaseServiceResponse<T>> _callSynchronizedService<T>(
    Future<HTTPCallerResponse> Function() t, {
    List<int> allowStatus = const [200],
  }) async {
    if (requestTimeout == null) {
      return _onServiceException<T>(t, allowStatus: allowStatus);
    }
    await _lock.synchronized(() async {
      return _onServiceException<T>(t, allowStatus: allowStatus);
    });
    return _onServiceException<T>(t, allowStatus: allowStatus);
  }

  Future<BaseServiceResponse<T>> serviceRequest<T>(
      BaseServiceRequestParams request,
      {List<int> allowStatus = const [200],
      Uri? uri,
      Duration? timeout,
      HTTPResponseType? responseType,
      ServiceInfo? currentProvider}) async {
    BaseServiceResponse<T>? response;
    final toUri = uri ?? request.toUri(service.url);
    final ProviderAuthenticated? authenticated =
        currentProvider?.authenticated ?? service.authenticated;
    try {
      final Map<String, String> headers = {
        if (request.type == RequestServiceType.post)
          'Content-Type': 'application/json',
        'Accept': 'application/json',
        ...request.headers
      };
      final type = _detectTemplateType<T>(responseType: responseType);
      response = await _callSynchronizedService<T>(() async {
        return switch (request.type) {
          RequestServiceType.get => await HTTPCaller.get(
              uri: toUri,
              timeout: timeout ?? defaultTimeOut,
              headers: headers,
              type: type,
              authenticated: authenticated),
          RequestServiceType.post => await HTTPCaller.post(
              uri: toUri,
              timeout: timeout ?? defaultTimeOut,
              headers: headers,
              body: request.body(),
              type: type,
              authenticated: authenticated)
        };
      }, allowStatus: allowStatus);

      return response;
    } finally {}
  }
}
