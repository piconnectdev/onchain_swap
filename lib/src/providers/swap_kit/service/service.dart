import 'package:blockchain_utils/service/models/params.dart';
import 'package:on_chain_swap/src/providers/swap_kit/core/core/core.dart';

typedef SwapKitServiceResponse<T> = BaseServiceResponse<T>;

mixin SwapKitServiceProvider
    implements BaseServiceProvider<SwapKitRequestDetails> {
  /// Example:
  /// @override
  /// Future<`SwapKitServiceResponse<T>`> doRequest<`T`>(SwapKitRequestDetails params,
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
  Future<SwapKitServiceResponse<T>> doRequest<T>(SwapKitRequestDetails params,
      {Duration? timeout});
}
