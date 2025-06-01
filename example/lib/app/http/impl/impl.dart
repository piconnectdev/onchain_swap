import 'dart:async';
import 'package:onchain_swap_example/app/error/exception.dart';
import 'package:onchain_swap_example/app/http/http.dart';
import 'package:onchain_swap_example/app/utils/method.dart';
import 'package:http/http.dart';
import 'package:on_chain_bridge/models/device/models/platform.dart';

mixin HttpImpl {
  Future<HTTPCallerResponse> makeCall(
      {required Uri uri,
      AppPlatform platform = AppPlatform.android,
      ProviderAuthenticated? authenticated,
      HTTPClientType clientType = HTTPClientType.cached,
      HTTPResponseType type = HTTPResponseType.binary,
      HTTPRequestType requestType = HTTPRequestType.get,
      Map<String, String>? headers,
      Object? params,
      Duration timeout = const Duration(seconds: 60)}) async {
    try {
      final HTTPCallerResponse response = switch (requestType) {
        HTTPRequestType.get => await HTTPCaller.get(
            uri: uri,
            headers: headers,
            timeout: timeout,
            type: type,
            clientType: clientType,
            authenticated: authenticated,
            platform: platform),
        HTTPRequestType.post => await HTTPCaller.post(
            uri: uri,
            clientType: clientType,
            headers: headers,
            timeout: timeout,
            body: params,
            type: type,
            platform: platform)
      };
      return response;
    } catch (e) {
      throw ApiProviderException(message: _getExceptionMessage(e));
    }
  }

  static String _getExceptionMessage(Object e) {
    if (e is TimeoutException) return "api_http_timeout_error";
    if (e is ClientException) return "api_http_client_error";
    return e.toString();
  }

  // static final ServicesHTTPCaller _serviceCaller = ServicesHTTPCaller();
  // HTTPServiceWorker get serviceCaller => _serviceCaller;
  static HTTPResponseType _detectTemplateType<T>(
      {HTTPResponseType? responseType}) {
    if (responseType != null) return responseType;
    if (dynamic is T) return HTTPResponseType.json;
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

  Future<MethodResult<T>> httpGet<T>(String uri,
      {Map<String, String>? headers,
      Duration timeout = const Duration(seconds: 30),
      HTTPResponseType? responseType,
      HTTPClientType clientType = HTTPClientType.single,
      ProviderAuthenticated? authenticated}) async {
    final rType = _detectTemplateType<T>(responseType: responseType);
    return await MethodUtils.call<T>(() async {
      final r = await makeCall(
        uri: Uri.parse(uri),
        timeout: timeout,
        type: rType,
        clientType: clientType,
        headers: headers,
        authenticated: authenticated,
      );
      return r.successResult<T>();
    });
  }

  Future<MethodResult<T>> httpPost<T>(String uri,
      {Map<String, String>? headers,
      Object? params,
      Duration timeout = const Duration(seconds: 30),
      HTTPResponseType? responseType,
      HTTPClientType clientType = HTTPClientType.single,
      ProviderAuthenticated? authenticated}) async {
    final rType = _detectTemplateType<T>(responseType: responseType);
    return await MethodUtils.call<T>(() async {
      final r = await makeCall(
        uri: Uri.parse(uri),
        requestType: HTTPRequestType.post,
        timeout: timeout,
        type: rType,
        clientType: clientType,
        params: params,
        headers: headers,
        authenticated: authenticated,
      );
      return r.successResult<T>();
    });
  }

  Future<MethodResult<List<int>>> makeStream(
      {required String uri,
      Map<String, String> headers = const {},
      OnStreamReapose? onProgress}) async {
    return await MethodUtils.call(() async {
      final r = await HTTPCaller.getStream(
          uri: Uri.parse(uri), headers: headers, onProgress: onProgress);
      return r.successResult<List<int>>();
    });
  }
}
