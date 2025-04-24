import 'package:blockchain_utils/exception/exception/rpc_error.dart';
import 'package:blockchain_utils/helper/helper.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:blockchain_utils/utils/numbers/utils/bigint_utils.dart';
import 'package:onchain_swap/src/swap/transaction/client/core/client.dart';
import 'package:onchain_swap/src/exception/exception.dart';
import 'package:onchain_swap/src/swap/transaction/types/types.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:onchain_swap/src/swap/types/types.dart';

class CosmosClient extends NetworkClient<SwapCosmosNetwork, TendermintProvider,
    CosmosBaseAddress> {
  static const Map<String, String> forked = {
    "thorchain-1": "https://thornode.ninerealms.com/thorchain/constants",
    "mayachain-mainnet-v1":
        "https://mayanode.mayachain.info/mayachain/constants"
  };
  final CosmosSdkChain? chainInfo;
  const CosmosClient(
      {required super.provider,
      required super.network,
      required this.chainInfo});

  Future<String> chainId() async {
    final chainStatus = await provider.request(TendermintRequestStatus());
    return chainStatus["node_info"]["network"];
  }

  static Future<CosmosClient> check(
      {required TendermintProvider provider,
      required SwapCosmosNetwork network,
      required CosmosSdkChain? chainInfo}) async {
    final client = CosmosClient(
        provider: provider, network: network, chainInfo: chainInfo);
    final chainId = await client.chainId();
    if (chainId != network.identifier) {
      throw DartOnChainSwapPluginException(
          "The Chain ID is not compatible with the current network.");
    }

    return CosmosClient(
        provider: provider, network: network, chainInfo: chainInfo);
  }

  Future<List<Coin>> getAccountCoins(CosmosBaseAddress address) async {
    final request = QuerySpendableBalancesRequest(address: address);
    final result =
        await provider.request(TendermintRequestAbciQuery(request: request));
    return result.balances;
  }

  Future<BaseAccount> getBaseAccount(CosmosBaseAddress address) async {
    try {
      final request = QueryAccountRequest(address);
      final result =
          await provider.request(TendermintRequestAbciQuery(request: request));
      return result.account.baseAccount;
    } on RPCError catch (e) {
      if (e.errorCode == 22) {
        throw DartCosmosSdkPluginException("Account not found.");
      }
      rethrow;
    }
  }

  Future<SimulateResponse> simulateTransaction(List<int> txBytes,
      {List<CosmosMessage> txMessages = const []}) async {
    return await provider
        .request(TendermintRequestAbciQuery(request: SimulateRequest(txBytes)));
  }

  @override
  Future<BigInt> getBalance(CosmosBaseAddress address) async {
    if (chainInfo == null) {
      throw DartOnChainSwapPluginException("Missing cosmos chain information.");
    }

    final coins = await getAccountCoins(address);
    final nativeToken =
        coins.firstWhereNullable((e) => e.denom == chainInfo!.native.denom);
    return nativeToken?.amount ?? BigInt.zero;
  }

  Future<String> broadcastTransaction(List<int> txRaw) async {
    final result = await provider.request(TendermintRequestBroadcastTxCommit(
        BytesUtils.toHexString(txRaw, prefix: "0x")));
    if (!result.isSuccess) {
      throw RPCError(
        message: result.error ?? "",
        errorCode: result.errorCode,
        details: result.error == null ? result.toJson() : null,
      );
    }
    return result.hash;
  }

  Future<ThorNodeNetworkConstants> getThorNodeConstants() async {
    throw UnimplementedError();
  }

  Future<bool> isEthermint() async {
    try {
      await provider.request(TendermintRequestAbciQuery(
          request: EvmosEthermintEVMV1QueryParamsRequest()));
      return true;
    } on RPCError catch (e) {
      if (e.errorCode == 6) return false;
      rethrow;
    }
  }

  Future<BigRational> getEthermintBaseFee() async {
    final chainStatus = await provider.request(TendermintRequestAbciQuery(
        request: EvmosEthermintEVMV1QueryBaseFeeRequest()));
    return BigRational(BigintUtils.parse(chainStatus.baseFee));
  }

  Future<CosmosTransactionRequirment> getTransactionRequirment(
      CosmosBaseAddress address) async {
    if (chainInfo == null) {
      throw DartOnChainSwapPluginException("Missing cosmos chain information.");
    }
    final cosmosAccount = await getBaseAccount(address);
    BigInt? fixedFee;
    if (forked.containsKey(chainInfo!.chainId)) {
      final networkConst = await getThorNodeConstants();
      fixedFee = BigInt.from(networkConst.nativeTransactionFee);
    }
    final ethermint = await isEthermint();
    BigRational? ethermintTxFee;
    if (ethermint) {
      final fee = await getEthermintBaseFee();
      ethermintTxFee = fee;
    }
    return CosmosTransactionRequirment(
        account: cosmosAccount,
        fixedNativeGas: fixedFee,
        ethermintTxFee: ethermintTxFee);
  }
}
