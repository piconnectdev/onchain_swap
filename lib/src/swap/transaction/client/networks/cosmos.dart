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

class SwapCosmosClient implements BaseSwapCosmosClient {
  final TendermintProvider provider;
  final SwapCosmosNetwork network;
  String? _chainId;
  static const Map<String, String> forked = {
    "thorchain-1": "https://thornode.ninerealms.com/thorchain/constants",
    "mayachain-mainnet-v1":
        "https://mayanode.mayachain.info/mayachain/constants"
  };
  final CosmosSdkChain? networkInfo;
  SwapCosmosClient(
      {required this.provider,
      required this.network,
      required this.networkInfo});

  Future<String> chainId() async {
    if (_chainId != null) return _chainId!;
    final chainStatus = await provider.request(TendermintRequestStatus());
    _chainId = chainStatus["node_info"]?["network"];
    if (_chainId == null) {
      throw DartOnChainSwapPluginException(
          "Unexpected data received instead of the chain ID.");
    }
    return _chainId!;
  }

  static Future<SwapCosmosClient> check(
      {required TendermintProvider provider,
      required SwapCosmosNetwork network,
      required CosmosSdkChain? chainInfo}) async {
    final client = SwapCosmosClient(
        provider: provider, network: network, networkInfo: chainInfo);
    if (!(await client.initSwapClient())) {
      throw DartOnChainSwapPluginException(
          "The Chain ID is not compatible with the current network.");
    }

    return SwapCosmosClient(
        provider: provider, network: network, networkInfo: chainInfo);
  }

  Future<List<Coin>> getAddressCoins(CosmosBaseAddress address) async {
    final request = QuerySpendableBalancesRequest(address: address);
    final result =
        await provider.request(TendermintRequestAbciQuery(request: request));
    return result.balances;
  }

  Future<BaseAccount> getAccount(CosmosBaseAddress address) async {
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

  Future<SimulateResponse> simulateTx(List<int> txBytes,
      {List<CosmosMessage> txMessages = const []}) async {
    return await provider
        .request(TendermintRequestAbciQuery(request: SimulateRequest(txBytes)));
  }

  @override
  Future<BigInt> getBalance(CosmosBaseAddress address, {String? denom}) async {
    final coins = await getAddressCoins(address);
    final nativeToken = coins.firstWhereNullable(
        (e) => e.denom == (denom ?? chainInfo.native.denom));
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

  Future<CosmosSwapTransactionRequirment> getSwapTransactionRequirment(
      CosmosBaseAddress address) async {
    final cosmosAccount = await getAccount(address);
    BigInt? fixedFee;
    if (forked.containsKey(network.identifier)) {
      final networkConst = await getThorNodeConstants();
      fixedFee = BigInt.from(networkConst.nativeTransactionFee);
    }
    final ethermint = await isEthermint();
    BigRational? ethermintTxFee;
    if (ethermint) {
      final fee = await getEthermintBaseFee();
      ethermintTxFee = fee;
    }
    return CosmosSwapTransactionRequirment(
        account: cosmosAccount,
        fixedNativeGas: fixedFee,
        ethermintTxFee: ethermintTxFee);
  }

  @override
  CosmosSwapNetworkReuirment get chainInfo {
    if (networkInfo == null) {
      throw DartOnChainSwapPluginException("Missing cosmos chain information.");
    }
    return CosmosSwapNetworkReuirment(
        native: networkInfo!.native, feeTokens: networkInfo!.fees);
  }

  @override
  Future<bool> initSwapClient() async {
    final chainId = await this.chainId();
    return chainId == network.identifier;
  }

  @override
  Future<SwapCosmosAccountAssetBalance> getAccountsAssetBalance(
      CosmosSwapAsset asset, CosmosBaseAddress account) async {
    return SwapCosmosAccountAssetBalance(
        address: account,
        balance: await getBalance(account, denom: asset.denom),
        asset: asset);
  }

  @override
  Future<BigInt?> getBlockHeight() async {
    final block = await provider
        .request(TendermintRequestAbciQuery(request: GetLatestBlockRequest()));
    return block.block?.header.height;
  }
}
