import 'package:blockchain_utils/utils/string/string.dart';
import 'package:onchain_swap_example/app/utils/string.dart';

class ApiProviderExceptionConst {
  static const int timeoutStatucCode = 10001;
}

class ApiProviderException implements Exception {
  static const List<int> validStatusCode = [
    404,
    400,
    401,
    403,
    405,
    408,
    500,
    503
  ];

  final String message;
  final int? statusCode;
  final int? code;
  final Map<String, dynamic>? responseData;

  bool get isTimeout => code == ApiProviderExceptionConst.timeoutStatucCode;
  ApiProviderException._({
    required this.message,
    this.statusCode,
    this.code,
    this.responseData,
  });
  factory ApiProviderException({Object? message, int? statusCode, int? code}) {
    final defaultError = validStatusCode.contains(statusCode)
        ? "http_error_$statusCode"
        : "request_error";
    if (message == null) {
      final msg = validStatusCode.contains(statusCode)
          ? "http_error_$statusCode"
          : "request_error";
      return ApiProviderException._(
          message: msg, code: code, statusCode: statusCode);
    }
    if (message is String && StrUtils.isHtml(message)) {
      return ApiProviderException._(
          code: code, message: defaultError, statusCode: statusCode);
    }
    final Map<String, dynamic>? decode = StringUtils.tryToJson(message);
    String? msg = (decode?["message"] ?? decode?["error"])?.toString();
    if (msg == null && message is String) {
      msg = message;
    }
    return ApiProviderException._(
        code: code,
        message: msg ?? defaultError,
        statusCode: statusCode,
        responseData: decode);
  }
  @override
  String toString() {
    return message;
  }
}
