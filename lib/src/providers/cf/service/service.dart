import 'package:on_chain_swap/src/providers/cf/core/core.dart';

import 'package:blockchain_utils/service/models/params.dart';

typedef CfServiceResponse<T> = BaseServiceResponse<T>;

mixin CfServiceProvider implements BaseServiceProvider<CfRequestDetails> {
  /// Example:
  /// @override
  /// Future<`CfServiceResponse<T>`> doRequest<`T`>(CfRequestDetails params,
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
  Future<CfServiceResponse<T>> doRequest<T>(CfRequestDetails params,
      {Duration? timeout});
}
