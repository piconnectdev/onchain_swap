import 'package:blockchain_utils/service/models/params.dart';
import 'package:onchain_swap/src/providers/skip_go/core/core/core.dart';

typedef SkipGoApiServiceResponse<T> = BaseServiceResponse<T>;

mixin SkipGoApiServiceProvider
    implements BaseServiceProvider<SkipGoApiRequestDetails> {
  /// Example:
  /// @override
  /// Future<`SkipGoApiServiceResponse<T>`> doRequest<`T`>(SkipGoApiRequestDetails params,
  ///     {Duration? timeout}) async {
  /// if (params.type.isPostRequest) {
  ///   final response = await client
  ///       .post(params.toUri(corretUrl),
  ///           headers: params.headers, body: params.body())
  ///       .timeout(timeout ?? defaultRequestTimeout);
  ///   return params.toResponse(response.bodyBytes, response.statusCode);
  /// }
  /// final response = await client
  ///     .get(params.toUri(corretUrl), headers: params.headers)
  ///     .timeout(timeout ?? defaultRequestTimeout);
  /// return params.toResponse(response.bodyBytes, response.statusCode);
  /// }
  @override
  Future<SkipGoApiServiceResponse<T>> doRequest<T>(
      SkipGoApiRequestDetails params,
      {Duration? timeout});
}
