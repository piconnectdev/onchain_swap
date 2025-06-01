import 'package:on_chain_bridge/on_chain_bridge.dart';
import 'package:on_chain_bridge/platform_interface.dart';

mixin AppNativeMethods {
  static OnChainBridgeInterface platform = PlatformInterface.instance;
}
