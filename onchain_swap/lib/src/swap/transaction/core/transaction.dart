import 'package:blockchain_utils/helper/extensions/extensions.dart';
import 'package:onchain_swap/src/swap/transaction/transaction.dart';
import 'package:onchain_swap/src/swap/types/types.dart';

enum TransactionOperationStep {
  client,
  generateTx,
  signing,
  broadcast,
  txHash,
  complete
}

typedef ONOPERATIONSTATUS = void Function(TransactionOperationStep,
    {String? transactionHash});

abstract class SwapRouteTransactionBuilder<
    ADDRESS,
    NETWORK extends SwapNetwork,
    CLIENT extends NetworkClient,
    TRANSACTION extends Web3Transaction,
    SIGNER extends Web3Signer,
    OPERATION extends SwapRouteTransactionOperation<NETWORK>> {
  SwapRouteTransactionBuilder(
      {required List<OPERATION> operations,
      required this.params,
      required this.route})
      : operations = operations.immutable;
  final List<OPERATION> operations;
  final SwapRoute route;
  final SwapRouteGeneralTransactionBuilderParam params;
  Future<void> buildTransactions(
      {required GETNETWORK<CLIENT, NETWORK> client,
      required GETSIGNER<SIGNER, ADDRESS> signer,
      required ONOPERATIONSTATUS stepsCallBack});
}

abstract class SwapRouteTransactionOperation<NETWORK> {
  final NETWORK network;
  const SwapRouteTransactionOperation({required this.network});
}

abstract class SwapRouteTransactionTransferDetails<NETWORK extends SwapNetwork>
    implements SwapRouteTransactionOperation<NETWORK> {
  abstract final NETWORK network;
  abstract final SwapAmount amount;
  abstract final String? memo;
  abstract final String sourceAddress;
  abstract final String destinationAddress;
  abstract final String? tokenAddress;
}

abstract class SwapRouteTransactionContractDetails<NETWORK extends SwapNetwork>
    implements SwapRouteTransactionOperation<NETWORK> {
  abstract final String sourceAddress;
  abstract final String contractAddress;
  abstract final String data;
  abstract final String functionName;
  abstract final SwapAmount? amount;
}
