import 'package:onchain_swap_example/app/models/models/setting.dart';
import 'package:onchain_swap/onchain_swap.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:onchain_swap_example/api/services/types/types.dart';
import 'package:onchain_swap_example/app/native_impl/core/core.dart';
import 'package:onchain_swap_example/app/utils/platform/utils.dart';

mixin NetworkRepository {
  static const String _repositoryStorageId = 'network';
  static const String _appRepositoryID = 'app';
  CosmosSdkChainChains? _cosmosChains;

  Future<void> saveAppSetting(APPSetting setting) async {
    await _write(
        key: 'setting',
        value: setting.toCbor().toCborHex(),
        repositoryStorageId: _appRepositoryID);
  }

  Future<void> saveServiceProvider(
      {required ServiceInfo service, required SwapNetwork network}) async {
    final serviceData = service.toCbor().toCborHex();
    await _write(
        key: network.identifier,
        value: serviceData,
        repositoryStorageId: _repositoryStorageId);
  }

  Future<ServiceInfo?> loadServiceProvider(SwapNetwork network) async {
    final data = await _read(
        key: network.identifier, repositoryStorageId: _repositoryStorageId);
    if (data == null) return null;
    return ServiceInfo.deserialize(cborHex: data);
  }

  Future<CosmosSdkChainChains> loadCosmosChains() async {
    Future<CosmosSdkChainChains> loadChains() async {
      try {
        final json = await PlatformUtils.loadJson<Map<String, dynamic>>(
            "assets/chains.json",
            package: "cosmos_sdk");
        return CosmosSdkChainChains.fromJson(json);
      } catch (_) {
        return CosmosSdkChainChains(mainnet: [], testnet: []);
      }
    }

    return _cosmosChains ??= await loadChains();
  }

  static String _toKey(String storageId, String key) {
    return "ST_${storageId}_$key";
  }

  static Future<void> _write(
      {required String key,
      required String value,
      required String repositoryStorageId}) async {
    await AppNativeMethods.platform
        .writeSecure(_toKey(repositoryStorageId, key), value);
  }

  static Future<String?> _read(
      {required String key, required String repositoryStorageId}) async {
    return await AppNativeMethods.platform
        .readSecure(_toKey(repositoryStorageId, key));
  }
}
