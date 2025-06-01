import 'package:onchain_bridge/onchain_bridge.dart';
import 'package:onchain_bridge/platform_interface.dart';

mixin AppNativeMethods {
  static OnChainBridgeInterface platform = PlatformInterface.instance;
}
