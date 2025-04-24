import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/crypto/quick_crypto.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:onchain_swap/src/exception/exception.dart';
import 'package:onchain_swap/src/swap/transaction/client/core/client.dart';
import 'package:onchain_swap/src/swap/transaction/types/types.dart';
import 'package:onchain_swap/src/swap/types/types.dart';

class _BitcoinClientConst {
  static final BigRational testnetFeeRate = BigRational.parseDecimal('1.1');
}

class BitcoinClient extends NetworkClient<SwapBitcoinNetwork, ElectrumProvider,
    BitcoinBaseAddress> {
  const BitcoinClient({required super.provider, required super.network});

  static Future<BitcoinClient> check({
    required ElectrumProvider provider,
    required SwapBitcoinNetwork network,
  }) async {
    final client = BitcoinClient(provider: provider, network: network);
    final genesis = await client.genesisHash();
    if (!BytesUtils.bytesEqual(
        genesis, BytesUtils.fromHexString(network.genesis))) {
      throw DartOnChainSwapPluginException(
          "The Genesis Hash is not compatible with the current network.");
    }
    return client;
  }

  Future<List<ElectrumUtxo>> utxos(BitcoinBaseAddress address) async {
    final utxos = await provider.request(
        ElectrumRequestScriptHashListUnspent(scriptHash: address.pubKeyHash()));
    return utxos;
  }

  Future<BigRational> estimateFeePerByte(SwapBitcoinNetwork network) async {
    final fee = await provider.request(ElectrumRequestEstimateFee());
    if (fee == null) {
      if (!network.chainType.isMainnet) {
        return _BitcoinClientConst.testnetFeeRate;
      }
      throw DartOnChainSwapPluginException("Failed to fetch network fee rate.");
    }
    return BigRational(fee) / BigRational.from(1024);
  }

  @override
  Future<BigInt> getBalance(BitcoinBaseAddress address) async {
    final utxos = await provider.request(
        ElectrumRequestScriptHashListUnspent(scriptHash: address.pubKeyHash()));
    return utxos.fold<BigInt>(BigInt.zero, (a, b) => a + b.value);
  }

  Future<String> sendTransaction(BtcTransaction transaction) async {
    return await provider.request(ElectrumRequestBroadCastTransaction(
        transactionRaw: transaction.serialize()));
  }

  Future<List<PsbtUtxo>> getAccountsUtxos(
      List<BitcoinSpenderAddress> addresses) async {
    final utxos = await _getAccountsUtxo(addresses);
    return utxos.where((e) {
      final height = e.utxo.blockHeight;
      return height != null && height > 0;
    }).toList();
  }

  Future<List<int>> genesisHash() async {
    final header = await provider
        .request(ElectrumRequestBlockHeader(startHeight: 0, cpHeight: 0));
    return QuickCrypto.sha256DoubleHash(BytesUtils.fromHexString(header))
        .reversed
        .toList();
  }

  Future<List<PsbtUtxo>> _getAccountsUtxo(
      List<BitcoinSpenderAddress> addresses) async {
    final utxos = await Future.wait(addresses.map((e) async {
      return await provider.request(ElectrumRequestScriptHashListUnspent(
          scriptHash: e.address.baseAddress.pubKeyHash()));
    }));
    final utxoss = List.generate(utxos.length, (i) async {
      final request = addresses[i];
      final accountUtxos = utxos[i];
      final er = await Future.wait(accountUtxos
          .map(
              (e) => provider.request(ElectrumRequestGetRawTransaction(e.txId)))
          .toList());
      return List.generate(
        accountUtxos.length,
        (index) {
          return PsbtUtxo(
              utxo: accountUtxos[index].toUtxo(request.address.type),
              p2shRedeemScript: request.p2shreedemScript,
              p2wshWitnessScript: request.witnessScript,
              tx: er[index],
              scriptPubKey: request.address.baseAddress.toScriptPubKey(),
              xOnlyOrInternalPubKey: request.taprootInternal);
        },
      );
    });
    final e = await Future.wait(utxoss);
    return e.expand((e) => e).toList();
  }
}
