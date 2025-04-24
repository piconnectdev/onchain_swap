import 'package:blockchain_utils/service/models/params.dart';
import 'package:onchain_swap/src/exception/exception.dart';
import 'package:onchain_swap/src/swap/swap.dart';

abstract class NetworkClient<NETWORK extends SwapNetwork,
    PROVIDER extends BaseProvider, ADDRESS> {
  final PROVIDER provider;
  final NETWORK network;
  const NetworkClient({required this.network, required this.provider});
  Future<BigInt> getBalance(ADDRESS address);

  T cast<T extends NetworkClient>() {
    if (this is! T) {
      throw DartOnChainSwapPluginException("client casting failed.",
          details: {"excepted": "$T", "type": runtimeType.toString()});
    }
    return this as T;
  }
}
