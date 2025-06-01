import 'package:onchain_swap/src/providers/swap_kit/core/core.dart';
import 'package:onchain_swap/src/providers/swap_kit/models/types.dart';

/// The /tokens endpoint provides a list of tokens for a specified provider.
/// This endpoint requires a query parameter to determine which provider's tokens you want to retrieve.
class SwapKitRequestTokens
    extends SwapKitGetRequest<SwapKitProviderToken, Map<String, dynamic>> {
  final String provider;
  const SwapKitRequestTokens(this.provider);
  @override
  String get method => SwapKitMethods.tokens.url;

  @override
  Map<String, dynamic> get queryParameters => {"provider": provider};

  @override
  SwapKitProviderToken onResonse(Map<String, dynamic> result) {
    return SwapKitProviderToken.fromJson(result);
  }
}
