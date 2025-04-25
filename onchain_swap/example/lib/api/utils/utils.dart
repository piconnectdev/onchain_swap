import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:example/api/services/types/app_client.dart';
import 'package:onchain_swap/onchain_swap.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:example/api/services/electrum/services/electrum_service.dart';
import 'package:example/api/services/providers/ethereum.dart';
import 'package:example/api/services/providers/ethereum_ws.dart';
import 'package:example/api/services/providers/solana.dart';
import 'package:example/api/services/providers/substrate.dart';
import 'package:example/api/services/providers/substrate_ws.dart';
import 'package:example/api/services/providers/tendermint.dart';
import 'package:example/api/services/socket/core/socket_provider.dart';
import 'package:example/api/services/types/types.dart';
import 'package:example/app/error/exception/app.dart';
import 'package:mrt_native_support/platform_interface.dart';
import 'package:on_chain/ethereum/src/rpc/provider/provider.dart';
import 'package:on_chain/solana/solana.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class ProviderUtils {
  static const Map<String, List<ServiceInfo>> _publicNodes = {
    "1": [
      ServiceInfo(
          url: "wss://ethereum-rpc.publicnode.com",
          protocol: ServiceProtocol.websocket),
      ServiceInfo(
          url: "https://ethereum-rpc.publicnode.com",
          protocol: ServiceProtocol.http),
    ],
    "11155111": [
      ServiceInfo(
          url: "https://ethereum-sepolia.publicnode.com",
          protocol: ServiceProtocol.http),
    ],
    "421614": [
      ServiceInfo(
          url: "wss://arbitrum-sepolia-rpc.publicnode.com",
          protocol: ServiceProtocol.websocket),
    ],
    "8453": [
      ServiceInfo(
          url: "wss://base-rpc.publicnode.com",
          protocol: ServiceProtocol.websocket),
      ServiceInfo(
          url: "https://base-rpc.publicnode.com",
          protocol: ServiceProtocol.http),
    ],
    "56": [
      ServiceInfo(
          url: "wss://bsc-rpc.publicnode.com",
          protocol: ServiceProtocol.websocket),
      ServiceInfo(
          url: "https://bsc-rpc.publicnode.com",
          protocol: ServiceProtocol.http),
    ],
    "42161": [
      ServiceInfo(
          url: "wss://arbitrum-one-rpc.publicnode.com",
          protocol: ServiceProtocol.websocket),
      ServiceInfo(
          url: "https://arbitrum-one-rpc.publicnode.com",
          protocol: ServiceProtocol.http),
    ],
    "43114": [
      ServiceInfo(
          url: "wss://avalanche-c-chain-rpc.publicnode.com",
          protocol: ServiceProtocol.websocket),
      ServiceInfo(
          url: "https://avalanche-c-chain-rpc.publicnode.com",
          protocol: ServiceProtocol.http),
    ],
    "solana": [
      ServiceInfo(
          url: "https://api.mainnet-beta.solana.com",
          protocol: ServiceProtocol.http),
    ],
    "solana:testnet": [
      ServiceInfo(
          url: "https://api.devnet.solana.com", protocol: ServiceProtocol.http),
    ],
    "cosmoshub-4": [
      ServiceInfo(
          url: "https://cosmos-rpc.publicnode.com:443",
          protocol: ServiceProtocol.http),
    ],
    "kaiyo-1": [
      ServiceInfo(
          url: "https://kujira-rpc.publicnode.com:443",
          protocol: ServiceProtocol.http),
    ],
    "polkadot": [
      ServiceInfo(
          url: "https://rpc.polkadot.io", protocol: ServiceProtocol.http),
      ServiceInfo(
          url: "wss://rpc.polkadot.io", protocol: ServiceProtocol.websocket),
    ],
    "bitcoin": [
      ServiceInfo(url: "142.93.6.38:50002", protocol: ServiceProtocol.ssl),
      ServiceInfo(
          url: "wss://bitcoin.aranguren.org:50004",
          protocol: ServiceProtocol.websocket),
    ],
    "bitcoin:testnet": [
      ServiceInfo(
          url: "ws://testnet.aranguren.org:51003",
          protocol: ServiceProtocol.websocket),
      ServiceInfo(
          url: "wss://testnet.aranguren.org:51004",
          protocol: ServiceProtocol.websocket),
    ],

    /// chain flip testnet pdot
    // ws_endpoint = "wss://rpc-pdot.chainflip.io:443"
    // http_endpoint = "https://rpc-pdot.chainflip.io:443"
    "polkadot:testnet": [
      ServiceInfo(
          url: "wss://rpc-pdot.chainflip.io:443",
          protocol: ServiceProtocol.websocket),
    ],
    "bitcoincash": [
      ServiceInfo(url: "cbch.loping.net:62102", protocol: ServiceProtocol.ssl),
      ServiceInfo(
          url: "ws://cbch.loping.net:62103",
          protocol: ServiceProtocol.websocket),
    ],
    "dogecoin": [
      ServiceInfo(url: "cbch.loping.net:62102", protocol: ServiceProtocol.ssl),
      ServiceInfo(
          url: "ws://cbch.loping.net:62103",
          protocol: ServiceProtocol.websocket),
    ]
  };
  static List<ServiceInfo> getProvider(SwapNetwork network) {
    switch (network.type) {
      case SwapChainType.ethereum:
        return _publicNodes[network.identifier]
                ?.where((e) => e.protocol
                    .supportOnThisPlatform(PlatformInterface.appPlatform))
                .toList() ??
            [];
      default:
        String identifier = network.identifier;
        if (!network.chainType.isMainnet) {
          identifier += ":testnet";
        }
        return _publicNodes[identifier]
                ?.where((e) => e.protocol
                    .supportOnThisPlatform(PlatformInterface.appPlatform))
                .toList() ??
            [];
    }
  }

  static Future<AppClient> buildClient(
      {required SwapNetwork network,
      required ServiceInfo provider,
      CosmosSdkChain? cosmosChain}) async {
    switch (network.type) {
      case SwapChainType.solana:
        final client = await SolanaClient.check(
            provider: SolanaProvider(SolanaHTTPService(service: provider)),
            network: network.cast());

        return AppClient(client: client, dispose: () {});
      case SwapChainType.cosmos:
        if (cosmosChain == null) {
          throw AppException("missin_cosmos_chain_info_err");
        }
        return AppClient(
          client: await CosmosClient.check(
              provider:
                  TendermintProvider(TendermintHTTPService(service: provider)),
              network: network.cast(),
              chainInfo: cosmosChain),
        );
      case SwapChainType.polkadot:
        switch (provider.protocol) {
          case ServiceProtocol.http:
            return AppClient(
                client: await SubstrateClient.check(
                    provider: SubstrateProvider(
                        SubstrateHTTPService(service: provider)),
                    network: network.cast()));
          case ServiceProtocol.websocket:
            final service = SubstrateWebsocketService(service: provider);
            return AppClient(
                client: await SubstrateClient.check(
                    provider: SubstrateProvider(service),
                    network: network.cast()),
                dispose: () {
                  service.disposeService();
                });
          default:
            throw AppException("invalid_provider_protocol");
        }
      case SwapChainType.bitcoin:
        final service = ElectrumService.fromProvider(provider);
        return AppClient(
            client: await BitcoinClient.check(
                provider: ElectrumProvider(service), network: network.cast()),
            dispose: () {
              service.disposeService();
            });
      case SwapChainType.ethereum:
        switch (provider.protocol) {
          case ServiceProtocol.http:
            return AppClient(
                client: await EthereumClient.check(
                    provider: EthereumProvider(
                        EthereumHTTPService(service: provider)),
                    network: network.cast()));
          case ServiceProtocol.websocket:
            final service = EthereumWebsocketService(service: provider);
            return AppClient(
              client: await EthereumClient.check(
                  provider: EthereumProvider(service), network: network.cast()),
              dispose: () {
                service.disposeService();
              },
            );
          default:
            throw AppException("invalid_provider_protocol");
        }
    }
  }
}
