import 'dart:async';
import 'package:onchain_swap/src/swap/transaction/const/const.dart';
import 'package:on_chain/ethereum/ethereum.dart';
import 'package:onchain_swap/src/swap/transaction/client/core/client.dart';
import 'package:onchain_swap/src/exception/exception.dart';
import 'package:onchain_swap/src/swap/types/types.dart';

class EthereumClient
    extends NetworkClient<SwapEthereumNetwork, EthereumProvider, ETHAddress> {
  const EthereumClient({required super.provider, required super.network});
  static Future<EthereumClient> check({
    required EthereumProvider provider,
    required SwapEthereumNetwork network,
  }) async {
    final client = EthereumClient(provider: provider, network: network);
    final chainId = await client.getChainId();
    if (chainId != network.chainId) {
      throw DartOnChainSwapPluginException(
          "The Chain ID is not compatible with the current network.");
    }
    return EthereumClient(provider: provider, network: network);
  }

  @override
  Future<BigInt> getBalance(ETHAddress address) async {
    return await provider
        .request(EthereumRequestGetBalance(address: address.address));
  }

  Future<BigInt> getChainId() async {
    return await provider.request(EthereumRequestGetChainId());
  }

  Future<BigInt> getAllowance({
    required ETHAddress contract,
    required ETHAddress owner,
    required ETHAddress spender,
  }) async {
    final function = EthereumAbiCons.getAllowance;
    final result = await provider.request(EthereumRequestCall.fromMethod(
        contractAddress: contract.address,
        function: function,
        params: [owner, spender]));
    return (result as List)[0];
  }

  Future<BigInt> getERC20TokenBalance(
      {required ETHAddress address, required ETHAddress contract}) async {
    final function = EthereumAbiCons.erc20BalaceFragment;
    final result = await provider.request(EthereumRequestCall.fromMethod(
        contractAddress: contract.address,
        function: function,
        params: [address]));
    return (result as List)[0];
  }

  Future<TransactionReceipt> trackTransaction(
      {required String transactionId,
      Duration timeout = const Duration(minutes: 5),
      Duration periodicTimeOut = const Duration(seconds: 3)}) async {
    Timer? timer;
    try {
      final Completer<TransactionReceipt> completer =
          Completer<TransactionReceipt>();
      timer = Timer.periodic(periodicTimeOut, (t) async {
        final receipt = await provider
            .request(EthereumRequestGetTransactionReceipt(
                transactionHash: transactionId))
            .catchError((e, s) {
          return null;
        });
        if (receipt != null && !completer.isCompleted) {
          completer.complete(receipt);
        }
      });
      final receipt = await completer.future.timeout(timeout);
      return receipt;
    } on TimeoutException {
      throw DartOnChainSwapPluginException(
          "transaction confirmation failed within the allotted timeout.");
    } finally {
      timer?.cancel();
      timer = null;
    }
  }
}
