import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:onchain_swap/src/swap/constants/constants.dart';
import 'package:polkadot_dart/polkadot_dart.dart';
import 'package:onchain_swap/src/exception/exception.dart';
import 'package:onchain_swap/src/swap/transaction/transaction.dart';
import 'package:onchain_swap/src/swap/types/types.dart';

enum SwapRouteSubstrateTransactionStrategy { native }

class SwapRouteSubstrateTransactionBuilder extends SwapRouteTransactionBuilder<
    SubstrateAddress,
    SwapSubstrateNetwork,
    BaseSwapSubstrateClient,
    Web3TransactionSubstrate,
    Web3SignerSubstrate,
    SwapRouteSubstrateTransactionOperation> {
  SwapRouteSubstrateTransactionBuilder(
      {required super.route, required super.params, required super.operations});

  @override
  Future<void> buildTransactions(
      {required GETNETWORK<BaseSwapSubstrateClient, SwapSubstrateNetwork>
          client,
      required GETSIGNER<Web3SignerSubstrate, SubstrateAddress> signer,
      required ONOPERATIONSTATUS stepsCallBack}) async {
    for (final operation in operations) {
      stepsCallBack(TransactionOperationStep.client);
      final substrateClient = await checkRouteAndClient(client, operation);
      stepsCallBack(TransactionOperationStep.generateTx);
      final transaction = await operation._buildTransactions(substrateClient);
      stepsCallBack(TransactionOperationStep.signing);
      final signerInfo = await signer(operation.source);
      final signers = await signerInfo.signers();
      signers.firstWhere((e) => e == operation.source,
          orElse: () => throw DartOnChainSwapPluginException(
              "None of the connected accounts match the source address of the transaction."));
      final signature = await signerInfo.signTransaction(transaction);

      final signatureBytes = BytesUtils.fromHexString(signature);
      final multisignature =
          SubstrateMultiSignature.deserialize(signatureBytes);
      final ExtrinsicSignature extrinsicSignature = ExtrinsicSignature(
          signature: multisignature,
          address: operation.source.toMultiAddress(),
          era: transaction.payload.era,
          tip: transaction.payload.tip,
          nonce: transaction.payload.nonce,
          mode: transaction.mode ?? 0);
      final extrinsic = Extrinsic(
          signature: extrinsicSignature,
          methodBytes: transaction.payload.method,
          version: transaction.version);
      stepsCallBack(TransactionOperationStep.broadcast);
      final result =
          await substrateClient.submitExtrinsicAndWatch(extrinsic: extrinsic);
      stepsCallBack(TransactionOperationStep.txHash,
          transactionHash: result.transactionHash);
    }
  }
}

abstract class SwapRouteSubstrateTransactionOperation
    extends SwapRouteTransactionOperation<SwapSubstrateNetwork> {
  final String? memo;
  final SubstrateAddress source;
  final SwapAmount amount;
  final SwapRouteSubstrateTransactionStrategy strategy;
  const SwapRouteSubstrateTransactionOperation(
      {required this.source,
      required this.amount,
      required super.network,
      required this.strategy,
      this.memo});
  Future<Web3TransactionSubstrate> _buildTransactions(
      BaseSwapSubstrateClient client);
}

class SwapRouteSubstrateNativeTransactionOperation
    extends SwapRouteSubstrateTransactionOperation
    implements SwapRouteTransactionTransferDetails<SwapSubstrateNetwork> {
  final SubstrateAddress destination;
  SwapRouteSubstrateNativeTransactionOperation(
      {required super.amount,
      required super.source,
      required this.destination,
      required super.network,
      super.memo})
      : super(strategy: SwapRouteSubstrateTransactionStrategy.native);

  List<int> _encode(MetadataApi metadata) {
    final Map<String, dynamic> input = {
      "transfer_allow_death": {
        "dest": {"Id": destination.toBytes()},
        "value": amount.amount
      }
    };
    return metadata.encodeCall(
        palletNameOrIndex: "balances", value: input, fromTemplate: false);
  }

  Future<Web3TransactionSubstrate> _buildTransactions(
      BaseSwapSubstrateClient client) async {
    final balance = await client.getBalance(source);
    if (balance < amount.amount) {
      throw SwapConstants.insufficientTokenBalance;
    }
    final block = await client.transactionBlockRequirment();
    final runtime = client.api.runtimeVersion();
    final nonce = await client.getAccountNonce(source);
    final extersinc = client.api.metadata.extrinsicInfo();
    if (extersinc.isEmpty) {
      throw DartOnChainSwapPluginException("Unsported metadata extersinc.");
    }
    final ex = extersinc.first;

    return Web3TransactionSubstrate(
        address: source,
        blockHash: block.blockHashBytes,
        blockNumber: block.blockNumber,
        era: block.era,
        genesisHash: block.genesisBlock.serialize(),
        method: _encode(client.api),
        nonce: nonce,
        specVersion: runtime.specVersion,
        transactionVersion: runtime.transactionVersion,
        signedExtensions:
            ex.extrinsic.map((e) => e.name).whereType<String>().toList(),
        version: ex.version);
  }

  @override
  String get destinationAddress => destination.address;

  @override
  String get sourceAddress => source.address;

  final String? tokenAddress = null;
}
