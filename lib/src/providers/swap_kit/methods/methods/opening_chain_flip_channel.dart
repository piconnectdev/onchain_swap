import 'package:onchain_swap/src/providers/swap_kit/core/core.dart';
import 'package:onchain_swap/src/providers/swap_kit/models/types.dart';

/// To initiate a swap through the CHAINFLIPor CHAINFLIP_STREAMINGproviders, a deposit channel must be opened first.
class SwapKitRequestChainFlipOpenDepositChannel extends SwapKitPostRequest<
    SwapKitChainFlipDepositChannel, Map<String, dynamic>> {
  final SwapKitRouteMetaChainFlip quoteMeta;
  const SwapKitRequestChainFlipOpenDepositChannel(this.quoteMeta);
  @override
  String get method => SwapKitMethods.chainflipOpenDepositChannel.url;

  @override
  SwapKitChainFlipDepositChannel onResonse(Map<String, dynamic> result) {
    return SwapKitChainFlipDepositChannel.fromJson(result);
  }

  @override
  Map<String, dynamic> body() {
    return quoteMeta.toJson();
  }
}
