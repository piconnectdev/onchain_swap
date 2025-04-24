import 'dart:async';
import 'package:on_chain/on_chain.dart';
import 'package:onchain_swap/src/swap/transaction/client/core/client.dart';
import 'package:onchain_swap/src/exception/exception.dart';
import 'package:onchain_swap/src/swap/types/types.dart';
import 'package:onchain_swap/src/swap/transaction/types/types.dart';

class SolanaClient
    extends NetworkClient<SwapSolanaNetwork, SolanaProvider, SolAddress> {
  const SolanaClient({required super.provider, required super.network});
  static Future<SolanaClient> check(
      {required SolanaProvider provider,
      required SwapSolanaNetwork network}) async {
    final client = SolanaClient(provider: provider, network: network);
    final genesis = await client.getGenesis();
    if (genesis != network.genesis) {
      throw DartOnChainSwapPluginException(
          "The Genesis Hash is not compatible with the current network.");
    }
    return client;
  }

  Future<String> getGenesis() async {
    return await provider.request(SolanaRequestGetGenesisHash());
  }

  Future<SolanaAccountInfo?> getAccountInfo(SolAddress address) async {
    final info =
        await provider.request(SolanaRequestGetAccountInfo(account: address));
    return info;
  }

  @override
  Future<BigInt> getBalance(SolAddress address) async {
    final account = await getAccountInfo(address);
    return account?.lamports ?? BigInt.zero;
  }

  Future<SimulateTranasctionResponse> simulate(
      {required SolanaTransaction transaction,
      SolAddress? account,
      bool replaceRecentBlockhash = true,
      bool sigVerify = false,
      Commitment? commitment = Commitment.processed,
      MinContextSlot? minContextSlot}) async {
    return await provider.request(
      SolanaRequestSimulateTransaction(
          encodedTransaction: transaction.serializeString(
              encoding: TransactionSerializeEncoding.base64),
          sigVerify: sigVerify,
          replaceRecentBlockhash: replaceRecentBlockhash,
          encoding: SolanaRequestEncoding.base64,
          commitment: Commitment.processed,
          minContextSlot: minContextSlot,
          accounts: account == null
              ? null
              : RPCAccountConfig(
                  addresses: [account],
                  encoding: SolanaRequestEncoding.base64)),
    );
  }

  Future<SolAddress> getBlockHash() async {
    final blockHash =
        await provider.request(const SolanaRequestGetLatestBlockhash());
    return blockHash.blockhash;
  }

  Future<SignatureStatus?> getSignatureStatuses(String signature) async {
    final statuses = await provider
        .request(SolanaRequestGetSignatureStatuses(signatures: [signature]));
    return statuses.elementAt(0);
  }

  Future<TransactionConfirmationStatus> trackTransaction(
      {required String transactionId,
      Duration timeout = const Duration(minutes: 1),
      Duration periodicTimeOut = const Duration(seconds: 2)}) async {
    Timer? timer;
    try {
      final Completer<TransactionConfirmationStatus> completer =
          Completer<TransactionConfirmationStatus>();
      timer = Timer.periodic(periodicTimeOut, (t) async {
        final receipt = await getSignatureStatuses(transactionId);
        if (receipt != null) {
          if (receipt.err != null) {
            completer.completeError(DartOnChainSwapPluginException(
                "Solana transaction simulation failed with error: ${receipt.err}"));
          } else {
            final status = receipt.confirmationStatus;
            if (status == TransactionConfirmationStatus.finalized) {
              completer.complete(status);
            }
          }
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

  Future<String> sendTransaction(SolanaTransaction transaction,
      {int? maxRetries,
      bool skipPreflight = false,
      int? minContextSlot,
      Commitment? commitment,
      SolanaRequestEncoding encoding = SolanaRequestEncoding.base64}) async {
    return await provider.request(SolanaRequestSendTransaction(
        encodedTransaction: transaction.serializeString(
          encoding: encoding == SolanaRequestEncoding.base64
              ? TransactionSerializeEncoding.base64
              : TransactionSerializeEncoding.base58,
        ),
        encoding: encoding,
        skipPreflight: skipPreflight,
        maxRetries: maxRetries,
        commitment: skipPreflight ? Commitment.processed : commitment,
        minContextSlot: minContextSlot == null
            ? null
            : MinContextSlot(slot: minContextSlot)));
  }

  Future<SolanaTokenPDAInfo> getTokenAccountAddress(
      {required SolAddress account,
      required SolAddress mint,
      SolAddress? tokenProgramId}) async {
    if (tokenProgramId == null) {
      final mintAccount = await getAccountInfo(mint);
      if (mintAccount == null) {
        throw DartOnChainSwapPluginException(
            "Invalid token address. mint account not found.");
      }
      tokenProgramId = mintAccount.owner;
      if (tokenProgramId != SPLTokenProgramConst.token2022ProgramId &&
          tokenProgramId != SPLTokenProgramConst.tokenProgramId) {
        throw DartOnChainSwapPluginException("Invalid mint account owner.",
            details: {"owner": tokenProgramId.address, "mint": mint.address});
      }
    }
    final pda = AssociatedTokenAccountProgramUtils.associatedTokenAccount(
        mint: mint,
        owner: account,
        tokenProgramId: tokenProgramId,
        allowOwnerOffCurve: true);
    return SolanaTokenPDAInfo(
        address: account,
        pdaAddress: pda.address,
        tokenProgramId: tokenProgramId);
  }
}
