import 'package:on_chain_swap/src/providers/swap_kit/core/core.dart';
import 'package:on_chain_swap/src/providers/swap_kit/models/types.dart';

/// The /providers endpoint allows users to retrieve a comprehensive list of all available swap
/// providers integrated by SwapKit and their supported chains and metadata.
/// This endpoint does not require any parameters and always returns the full list of providers and their information.
class SwapKitRequestProviders extends SwapKitGetRequest<
    List<SwapKitProviderInfo>, List<Map<String, dynamic>>> {
  @override
  String get method => SwapKitMethods.providers.url;

  @override
  List<SwapKitProviderInfo> onResonse(List<Map<String, dynamic>> result) {
    return result.map(SwapKitProviderInfo.fromJson).toList();
  }
}
