import 'package:onchain_swap/src/swap/types/types.dart';

class SwapKitSwapConstants {
  // static const List<SwapServiceProvider> providers = [
  //   oneInch,
  //   // uniswapV3,
  //   // pancakeswap,
  //   // sushiswapV2,
  //   // traderjoeV2,
  //   // uniswapV2,
  // ];
  // static const chainflipStreaming = SwapServiceProvider(
  //   name: "Chainflip Streaming Exchange",
  //   identifier: "CHAINFLIP_STREAMING",
  //   logoUrl:
  //       "https://storage.googleapis.com/token-list-swapkit/images/eth.flip-0x826180541412d574cf1336d22c0c0a287822678a.png",
  //   url:
  //       "https://storage.googleapis.com/token-list-swapkit/chainflip_streaming.json",
  //   crossChain: true,
  //   service: SwapServiceType.swapKit,
  // );

  // static const thorchainProvider = SwapServiceProvider(
  //   name: "Thorchain Decentralized Liquidity",
  //   identifier: "THORCHAIN",
  //   logoUrl:
  //       "https://storage.googleapis.com/token-list-swapkit/images/thor.rune.png",
  //   url: "https://storage.googleapis.com/token-list-swapkit/thorchain.json",
  //   crossChain: true,
  //   service: SwapServiceType.swapKit,
  // );

  static const pangolinV1 = SwapServiceProvider(
    name: "Pangolin V1 DEX",
    identifier: "PANGOLIN_V1",
    logoUrl:
        "https://storage.googleapis.com/token-list-swapkit/images/avax.png-0x60781c2586d68229fde47564546784ab3faca982.png",
    url: "https://storage.googleapis.com/token-list-swapkit/pangolin_v1.json",
    service: SwapServiceType.swapKit,
  );

  // static const chainflip = SwapServiceProvider(
  //     name: "Chainflip Cross-Chain Swaps",
  //     identifier: "CHAINFLIP",
  //     logoUrl:
  //         "https://storage.googleapis.com/token-list-swapkit/images/eth.flip-0x826180541412d574cf1336d22c0c0a287822678a.png",
  //     url: "https://storage.googleapis.com/token-list-swapkit/chainflip.json",
  //     service: SwapServiceType.swapKit,
  //     crossChain: true);

  static const uniswapV3 = SwapServiceProvider(
    name: "Uniswap V3 DEX",
    identifier: "UNISWAP_V3",
    logoUrl:
        "https://storage.googleapis.com/token-list-swapkit/images/eth.uni-0x1f9840a85d5af5bf1d1762f925bdaddc4201f984.png",
    url: "https://storage.googleapis.com/token-list-swapkit/uniswap_v3.json",
    service: SwapServiceType.swapKit,
  );

  static const caviarV1 = SwapServiceProvider(
    name: "Caviar V1 Liquidity Pool",
    identifier: "CAVIAR_V1",
    logoUrl:
        "https://storage.googleapis.com/token-list-swapkit/images/xrd.caviar-resource_rdx1tkk83magp3gjyxrpskfsqwkg4g949rmcjee4tu2xmw93ltw2cz94sq.png",
    url: "https://storage.googleapis.com/token-list-swapkit/caviar_v1.json",
    service: SwapServiceType.swapKit,
  );

  static const jupiter = SwapServiceProvider(
    name: "Jupiter Swap Aggregator",
    identifier: "JUPITER",
    logoUrl: "",
    url: "https://storage.googleapis.com/token-list-swapkit/jupiter.json",
    service: SwapServiceType.swapKit,
  );

  static const camelotV3 = SwapServiceProvider(
    name: "Camelot V3 AMM",
    identifier: "CAMELOT_V3",
    logoUrl:
        "https://storage.googleapis.com/token-list-swapkit/images/arb.ooe-0xdcbf4cb83d27c408b30dd7f39bfcabd7176b1ba3.png",
    url: "https://storage.googleapis.com/token-list-swapkit/camelot_v3.json",
    service: SwapServiceType.swapKit,
  );

  // static const mayaProvider = SwapServiceProvider(
  //   name: "MayaChain Cross-Chain Liquidity",
  //   identifier: "MAYACHAIN",
  //   logoUrl:
  //       "https://storage.googleapis.com/token-list-swapkit/images/maya.cacao.png",
  //   url: "https://storage.googleapis.com/token-list-swapkit/mayachain.json",
  //   crossChain: true,
  //   service: SwapServiceType.swapKit,
  // );

  // static const mayachainStreaming = SwapServiceProvider(
  //   name: "MayaChain Streaming Swaps",
  //   identifier: "MAYACHAIN_STREAMING",
  //   logoUrl:
  //       "https://storage.googleapis.com/token-list-swapkit/images/maya.cacao.png",
  //   url:
  //       "https://storage.googleapis.com/token-list-swapkit/mayachain_streaming.json",
  //   crossChain: true,
  //   service: SwapServiceType.swapKit,
  // );

  static const pancakeswap = SwapServiceProvider(
    name: "PancakeSwap DEX",
    identifier: "PANCAKESWAP",
    logoUrl:
        "https://storage.googleapis.com/token-list-swapkit/images/bsc.cake-0x0e09fabb73bd3ade0a17ecc321fd13a19e81ce82.png",
    url: "https://storage.googleapis.com/token-list-swapkit/pancakeswap.json",
    service: SwapServiceType.swapKit,
  );

  static const sushiswapV2 = SwapServiceProvider(
    name: "SushiSwap V2 AMM",
    identifier: "SUSHISWAP_V2",
    logoUrl:
        "https://storage.googleapis.com/token-list-swapkit/images/eth.sushi-0x6b3595068778dd592e39a122f4f5a5cf09c90fe2.png",
    url: "https://storage.googleapis.com/token-list-swapkit/sushiswap_v2.json",
    service: SwapServiceType.swapKit,
  );

  static const thorchainStreaming = SwapServiceProvider(
    name: "Thorchain Streaming Swaps",
    identifier: "THORCHAIN_STREAMING",
    logoUrl:
        "https://storage.googleapis.com/token-list-swapkit/images/thor.rune.png",
    url:
        "https://storage.googleapis.com/token-list-swapkit/thorchain_streaming.json",
    crossChain: true,
    service: SwapServiceType.swapKit,
  );

  static const traderjoeV2 = SwapServiceProvider(
    name: "Trader Joe V2 DEX",
    identifier: "TRADERJOE_V2",
    logoUrl:
        "https://storage.googleapis.com/token-list-swapkit/images/avax.joe-0x6e84a6216ea6dacc71ee8e6b0a5b7322eebc0fdd.png",
    url: "https://storage.googleapis.com/token-list-swapkit/traderjoe_v2.json",
    service: SwapServiceType.swapKit,
  );

  static const uniswapV2 = SwapServiceProvider(
    name: "Uniswap V2 DEX",
    identifier: "UNISWAP_V2",
    logoUrl:
        "https://storage.googleapis.com/token-list-swapkit/images/eth.uni-0x1f9840a85d5af5bf1d1762f925bdaddc4201f984.png",
    url: "https://storage.googleapis.com/token-list-swapkit/uniswap_v2.json",
    service: SwapServiceType.swapKit,
  );
}
