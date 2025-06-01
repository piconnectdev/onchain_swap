import 'package:blockchain_utils/utils/utils.dart';

class AppException implements Exception {
  const AppException.error(this.message) : _argruments = null;
  final String message;
  AppException.invalidArgruments(List<String> this._argruments)
      : assert(_argruments.length == 2),
        message = "";
  const AppException(this.message) : _argruments = null;
  final List<String>? _argruments;
  @override
  String toString() {
    if (_argruments != null) {
      return "invalid_request";
    }
    // if (_argruments != null) {
    //   return "invalid data expected: ${_argruments[0]} got ${_argruments[1]}";
    // }
    return message;
  }

  @override
  bool operator ==(other) {
    if (other is! AppException) return false;
    return other.message == message &&
        CompareUtils.iterableIsEqual(_argruments, other._argruments);
  }

  @override
  int get hashCode => Object.hash(message, _argruments);
}

class AppExceptionConst {
  static const AppException dataVerificationFailed =
      AppException("data_verification_failed");
  static const AppException failedToLoadImage =
      AppException("failed_to_load_image");
  static AppException invalidData({String? messsage}) =>
      const AppException("data_verification_failed");
  static const AppException fileVerificationFiled =
      AppException("file_verification_fail");
  static const AppException invalidSerializationData =
      AppException("invalid_serialization_data");
  static const AppException invalidProviderInformation =
      AppException("invalid_provider_infomarion");
}
