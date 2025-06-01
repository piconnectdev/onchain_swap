import 'package:onchain_swap/src/swap/types/types.dart';

class SwapKitSwapServiceProvider extends SwapServiceProvider {
  const SwapKitSwapServiceProvider(
      {required super.name,
      required super.identifier,
      required super.logoUrl,
      required super.url,
      // required super.service,
      required super.crossChain})
      : super(service: SwapServiceType.swapKit);
}
