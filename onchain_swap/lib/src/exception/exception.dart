import 'package:blockchain_utils/blockchain_utils.dart';

class DartOnChainSwapPluginException extends BlockchainUtilsException {
  const DartOnChainSwapPluginException(String message,
      {Map<String, dynamic>? details})
      : super(message, details: details);
}
