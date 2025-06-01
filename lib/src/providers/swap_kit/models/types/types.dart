import 'package:blockchain_utils/helper/helper.dart';
import 'package:onchain_swap/src/utils/equatable.dart';
import 'package:onchain_swap/src/utils/extensions/json.dart';

class SwapKitProviderInfo {
  final String name;
  final String provider;
  final List<String> keywords;
  final int count;
  final String logoURI;
  final String url;
  final List<String> supportedActions;
  final List<String> supportedChainIds;

  SwapKitProviderInfo({
    required this.name,
    required this.provider,
    required this.keywords,
    required this.count,
    required this.logoURI,
    required this.url,
    required this.supportedActions,
    required this.supportedChainIds,
  });

  factory SwapKitProviderInfo.fromJson(Map<String, dynamic> json) {
    return SwapKitProviderInfo(
      name: json.as("name"),
      provider: json.as("provider"),
      keywords: json.asListOfString("keywords")!,
      count: json.asInt("count"),
      logoURI: json.as("logoURI"),
      url: json.as("url"),
      supportedActions: json.asListOfString("supportedActions")!,
      supportedChainIds: json.asListOfString("supportedChainIds")!,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'provider': provider,
      'keywords': keywords,
      'count': count,
      'logoURI': logoURI,
      'url': url,
      'supportedActions': supportedActions,
      'supportedChainIds': supportedChainIds,
    };
  }
}

class SwapKitToken with Equatable {
  /// The blockchain the token is associated with (e.g., ETH, BTC, SOL).
  final String chain;

  /// The contract address of the token (only provided if it is not the gas token of the network).
  final String? address;

  /// The ID of the chain. It could be a numeric ID (e.g., 42161 for Arbitrum) or a name like solana
  final String chainId;

  /// The ticker symbol of the token (e.g., ETH, BTC)
  final String ticker;

  /// An identifier for the token that combines chain and token address, used to identify the token in SwapKit API.
  final String identifier;

  /// The token symbol, which includes address information.
  final String? symbol;

  /// The full name of the token.
  final String? name;

  /// The number of decimal places the token supports.
  final int decimals;

  /// A URL pointing to the token's logo image.
  final String? logoURI;

  /// The identifier of the token on CoinGecko (if available)
  final String? coingeckoId;

  SwapKitToken({
    required this.chain,
    required this.chainId,
    required this.ticker,
    required this.identifier,
    required this.symbol,
    required this.name,
    required this.decimals,
    required this.logoURI,
    required this.coingeckoId,
    required this.address,
  });

  factory SwapKitToken.fromJson(Map<String, dynamic> json) {
    return SwapKitToken(
        chain: json.as("chain"),
        chainId: json.as("chainId"),
        ticker: json.as("ticker"),
        identifier: json.as("identifier"),
        symbol: json.as("symbol"),
        name: json.as("name"),
        decimals: json.asInt("decimals"),
        logoURI: json.as("logoURI"),
        coingeckoId: json.as("coingeckoId"),
        address: json.as("address"));
  }

  Map<String, dynamic> toJson() {
    return {
      'chain': chain,
      'chainId': chainId,
      'ticker': ticker,
      'identifier': identifier,
      'symbol': symbol,
      'name': name,
      'decimals': decimals,
      'logoURI': logoURI,
      'coingeckoId': coingeckoId,
      "address": address
    };
  }

  @override
  List get variabels => [chainId, identifier];
}

class SwapKitVersion {
  final int major;
  final int minor;
  final int patch;
  const SwapKitVersion(
      {required this.major, required this.minor, required this.patch});
  factory SwapKitVersion.fromJson(Map<String, dynamic> json) {
    return SwapKitVersion(
        major: json.as("major"),
        minor: json.as("minor"),
        patch: json.as("patch"));
  }
  Map<String, dynamic> toJson() {
    return {'major': major, 'patch': patch, 'minor': minor};
  }
}

class SwapKitProviderToken {
  /// The name of the provider specified in the query.
  final String provider;
  final String? name;

  /// The timestamp of when the response was generated.
  final String timestamp;
  final SwapKitVersion? version;
  final List<String>? keywords;

  /// The number of tokens included in the response.
  final int count;

  /// An array of token objects, each representing a token available for the specified provider.
  final List<SwapKitToken> tokens;

  SwapKitProviderToken({
    required this.provider,
    required this.name,
    required this.timestamp,
    required this.version,
    required this.keywords,
    required this.count,
    required this.tokens,
  });

  factory SwapKitProviderToken.fromJson(Map<String, dynamic> json) {
    return SwapKitProviderToken(
      provider: json.as("provider"),
      name: json.as("name"),
      timestamp: json.as("timestamp"),
      version: json.maybeAs(key: "version", onValue: SwapKitVersion.fromJson),
      keywords: json.asListOfString("keywords", throwOnNull: false),
      count: json.asInt("count"),
      tokens: json.asListOfMap("tokens")!.map(SwapKitToken.fromJson).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider': provider,
      'name': name,
      'timestamp': timestamp,
      'version': version,
      'keywords': keywords,
      'count': count,
      'tokens': tokens.map((e) => e.toJson()).toList(),
    };
  }
}

class SwapKitRouteFee {
  final String type;
  final String amount;
  final String asset;
  final String chain;
  final String protocol;
  const SwapKitRouteFee(
      {required this.type,
      required this.amount,
      required this.asset,
      required this.chain,
      required this.protocol});
  factory SwapKitRouteFee.fromJson(Map<String, dynamic> json) {
    return SwapKitRouteFee(
        type: json.as("type"),
        amount: json.as("amount"),
        asset: json.as("asset"),
        chain: json.as("chain"),
        protocol: json.as("protocol"));
  }

  Map<String, dynamic> toJson() {
    return {
      "type": type,
      "amount": amount,
      "asset": asset,
      "chain": chain,
      "protocol": protocol
    };
  }
}

class SwapKitRouteResponse {
  /// The routes array contains possible swap options, each identified by the providersobject at the start.
  final List<SwapKitRoute> routes;

  /// A unique identifier for the quote request.
  /// You can optionally store it to reference the quote provided by SwapKit at a later date.
  final String quoteId;
  SwapKitRouteResponse(
      {required List<SwapKitRoute> routes, required this.quoteId})
      : routes = routes.immutable;
  factory SwapKitRouteResponse.fromJson(Map<String, dynamic> json) {
    return SwapKitRouteResponse(
        routes: json.asListOfMap("routes")!.map(SwapKitRoute.fromJson).toList(),
        quoteId: json.as("quoteId"));
  }
  Map<String, dynamic> toJson() {
    return {
      "routes": routes.map((e) => e.toJson()).toList(),
      "quoteId": quoteId
    };
  }
}

class SwapKitRoute {
  /// List of providers available for this route (CHAINFLIP, THORHCAINetc.).
  final List<String> providers;

  /// The asset being sold (e.g., "ETH.ETH").
  final String sellAsset;

  /// Amount of the sell asset in smallest units.
  final String sellAmount;

  /// The asset being bought (e.g., "BTC.BTC")
  final String buyAsset;

  /// Estimated amount of the buy asset to be received
  final String expectedBuyAmount;

  /// Worst-case buy amount considering max slippage
  final String expectedBuyAmountMaxSlippage;

  /// Source address.
  final String sourceAddress;

  /// Destination address.
  final String destinationAddress;

  /// Address to send the initial transaction to
  final String? targetAddress;
  final String? inboundAddress;
  final String? expiration;

  /// Transaction memo, which can be used in UTXO chains directly.
  final String? memo;

  /// Expected total slippage
  final num totalSlippageBps;

  /// Estimated time for different phases of the swap.
  final SwapKitRouteEstimateTime? estimateTime;

  /// Potential warnings about this swap provider
  final List<SwapKitRouteWarning> warnings;

  /// Other information about the transaction.
  final SwapKitRouteMeta meta;

  /// List of fees applied to the swap (inbound, network, affiliate).
  final List<SwapKitRouteFee> fees;

  /// The different involved steps in the swap.
  final List<Map<String, dynamic>> legs;

  /// Transaction object for EVM chains, a PSBT object for BTC etc.
  final dynamic tx;
  SwapKitRoute(
      {required List<String> providers,
      required this.sellAsset,
      required this.sellAmount,
      required this.buyAsset,
      required this.expectedBuyAmount,
      required this.expectedBuyAmountMaxSlippage,
      required this.sourceAddress,
      required this.destinationAddress,
      required this.targetAddress,
      required this.inboundAddress,
      required this.expiration,
      required this.memo,
      required this.totalSlippageBps,
      required List<SwapKitRouteWarning> warnings,
      required this.meta,
      required List<SwapKitRouteFee> fees,
      required this.tx,
      required this.estimateTime,
      required List<Map<String, dynamic>> logs})
      : providers = providers.immutable,
        warnings = warnings.immutable,
        fees = fees.toImutableList,
        legs = logs.map((e) => e.immutable).toImutableList;
  factory SwapKitRoute.fromJson(Map<String, dynamic> json) {
    return SwapKitRoute(
        providers: json.asListOfString("providers")!,
        sellAsset: json.as("sellAsset"),
        sellAmount: json.as("sellAmount"),
        buyAsset: json.as("buyAsset"),
        expectedBuyAmount: json.as("expectedBuyAmount"),
        expectedBuyAmountMaxSlippage: json.as("expectedBuyAmountMaxSlippage"),
        sourceAddress: json.as("sourceAddress"),
        destinationAddress: json.as("destinationAddress"),
        targetAddress: json.as("targetAddress"),
        inboundAddress: json.as("inboundAddress"),
        expiration: json.as("expiration"),
        memo: json.as("memo"),
        totalSlippageBps: json.as("totalSlippageBps"),
        warnings: json
            .asListOfMap("warnings")!
            .map(SwapKitRouteWarning.fromJson)
            .toList(),
        meta: SwapKitRouteMeta.fromJson(json.asMap("meta")),
        fees: json.asListOfMap("fees")!.map(SwapKitRouteFee.fromJson).toList(),
        tx: json.as("tx"),
        estimateTime: json.maybeAs(
            key: "estimatedTime", onValue: SwapKitRouteEstimateTime.fromJson),
        logs: json.asListOfMap("legs")!);
  }
  Map<String, dynamic> toJson() {
    return {
      'providers': providers,
      'sellAsset': sellAsset,
      'sellAmount': sellAmount,
      'buyAsset': buyAsset,
      'expectedBuyAmount': expectedBuyAmount,
      'expectedBuyAmountMaxSlippage': expectedBuyAmountMaxSlippage,
      'sourceAddress': sourceAddress,
      'destinationAddress': destinationAddress,
      'targetAddress': targetAddress,
      'inboundAddress': inboundAddress,
      'expiration': expiration,
      'memo': memo,
      'totalSlippageBps': totalSlippageBps,
      'warnings': warnings.map((e) => e.toJson()).toList(),
      'meta': meta.toJson(),
      'fees': fees,
      'tx': tx,
      'estimatedTime': estimateTime?.toJson(),
      'legs': legs,
    };
  }
}

class SwapKitRouteAsset {
  final String asset;
  final num price;
  final String image;
  const SwapKitRouteAsset(
      {required this.asset, required this.price, required this.image});
  factory SwapKitRouteAsset.fromJson(Map<String, dynamic> json) {
    return SwapKitRouteAsset(
      asset: json.as("asset"),
      price: json.as("price"),
      image: json.as("image"),
    );
  }
  Map<String, dynamic> toJson() {
    return {"asset": asset, "price": price, "image": image};
  }
}

class SwapKitRouteChainFlipAsset {
  final String asset;
  final String chain;
  const SwapKitRouteChainFlipAsset({required this.asset, required this.chain});
  factory SwapKitRouteChainFlipAsset.fromJson(Map<String, dynamic> json) {
    return SwapKitRouteChainFlipAsset(
      asset: json.as("asset"),
      chain: json.as("chain"),
    );
  }
  Map<String, dynamic> toJson() {
    return {"asset": asset, "chain": chain};
  }
}

class SwapKitRouteChainFlipAffiliateFee {
  final String brokerAddress;
  final int feeBps;
  const SwapKitRouteChainFlipAffiliateFee(
      {required this.brokerAddress, required this.feeBps});
  factory SwapKitRouteChainFlipAffiliateFee.fromJson(
      Map<String, dynamic> json) {
    return SwapKitRouteChainFlipAffiliateFee(
      brokerAddress: json.as("brokerAddress"),
      feeBps: json.asInt("feeBps"),
    );
  }
  Map<String, dynamic> toJson() {
    return {"brokerAddress": brokerAddress, "feeBps": feeBps};
  }
}

class SwapKitRouteChainFlipRefundParameters {
  final String minPrice;
  final int retryDuration;
  final String refundAddress;
  const SwapKitRouteChainFlipRefundParameters({
    required this.minPrice,
    required this.retryDuration,
    required this.refundAddress,
  });
  factory SwapKitRouteChainFlipRefundParameters.fromJson(
      Map<String, dynamic> json) {
    return SwapKitRouteChainFlipRefundParameters(
        minPrice: json.as("minPrice"),
        retryDuration: json.asInt("retryDuration"),
        refundAddress: json.as("refundAddress"));
  }
  Map<String, dynamic> toJson() {
    return {
      "minPrice": minPrice,
      "retryDuration": retryDuration,
      "refundAddress": refundAddress
    };
  }
}

class SwapKitRouteMetaChainFlip {
  final SwapKitRouteChainFlipAsset sellAsset;
  final SwapKitRouteChainFlipAsset buyAsset;
  final String destinationAddress;
  final List<SwapKitRouteChainFlipAffiliateFee> affiliateFees;
  final SwapKitRouteChainFlipRefundParameters refundParameters;
  final Map<String, dynamic> response;
  SwapKitRouteMetaChainFlip(
      {required this.sellAsset,
      required this.buyAsset,
      required this.destinationAddress,
      required this.affiliateFees,
      required this.refundParameters,
      required Map<String, dynamic> response})
      : response = response.immutable;
  factory SwapKitRouteMetaChainFlip.fromJson(Map<String, dynamic> json) {
    return SwapKitRouteMetaChainFlip(
        sellAsset: SwapKitRouteChainFlipAsset.fromJson(json.asMap("sellAsset")),
        buyAsset: SwapKitRouteChainFlipAsset.fromJson(json.asMap("buyAsset")),
        destinationAddress: json.as("destinationAddress"),
        affiliateFees: json
            .asListOfMap("affiliateFees")!
            .map(SwapKitRouteChainFlipAffiliateFee.fromJson)
            .toList(),
        refundParameters: SwapKitRouteChainFlipRefundParameters.fromJson(
            json.asMap("refundParameters")),
        response: json);
  }
  Map<String, dynamic> toJson() {
    return response.clone();
  }
}

enum SwapKitRouteMetaTag {
  /// Best overall route based on output and speed.
  recommended("RECOMMENDED"),

  /// The route with the maximum output.
  cheapest("CHEAPEST"),

  /// The route with the shortest total estimated time.
  fastest("FASTEST");

  final String name;
  const SwapKitRouteMetaTag(this.name);
  static SwapKitRouteMetaTag fromName(String? name) {
    return values.firstWhere((e) => e.name == name);
  }
}

class SwapKitRouteMeta {
  /// The expected impact on market rates.
  final num priceImpact;
  final List<SwapKitRouteAsset> assets;

  /// The contract address for ERC-20 approvals.
  final String? approvalAddress;

  /// ["FASTEST", "RECOMMENDED", "CHEAPEST"]
  ///
  final List<SwapKitRouteMetaTag> tags;

  /// Details of affiliate commissions.
  final String affiliate;
  final String affiliateFee;
  final String? txType;

  /// Information necessary to open a deposit channel for the Chainflip providers.
  final SwapKitRouteMetaChainFlip? chainflip;
  const SwapKitRouteMeta(
      {required this.priceImpact,
      required this.assets,
      required this.approvalAddress,
      required this.tags,
      required this.affiliate,
      required this.affiliateFee,
      required this.txType,
      this.chainflip});
  factory SwapKitRouteMeta.fromJson(Map<String, dynamic> json) {
    return SwapKitRouteMeta(
        priceImpact: json.as("priceImpact"),
        assets: json
            .asListOfMap("assets")!
            .map(SwapKitRouteAsset.fromJson)
            .toList(),
        approvalAddress: json.as("approvalAddress"),
        tags: json
            .asListOfString("tags")!
            .map(SwapKitRouteMetaTag.fromName)
            .toList(),
        affiliate: json.as("affiliate"),
        affiliateFee: json.as("affiliateFee"),
        txType: json.as("txType"),
        chainflip: json.maybeAs(
            key: "chainflip", onValue: SwapKitRouteMetaChainFlip.fromJson));
  }
  Map<String, dynamic> toJson() {
    return {
      "priceImpact": priceImpact,
      "assets": assets.map((e) => e.toJson()).toList(),
      "approvalAddress": approvalAddress,
      "tags": tags.map((e) => e.name).toList(),
      "affiliate": affiliate,
      "affiliateFee": affiliateFee,
      "txType": txType
    };
  }
}

class SwapKitRouteEstimateTime {
  /// Time taken to receive the sell asset.
  final num inbound;

  /// Time taken for the swap process.
  final num swap;

  /// Time taken to transfer the bought asset to the destination. This includes the provider outbound time, not only the transaction time.
  final num outbound;

  /// The sum of all time estimates.
  final num total;
  const SwapKitRouteEstimateTime(
      {required this.inbound,
      required this.swap,
      required this.outbound,
      required this.total});
  factory SwapKitRouteEstimateTime.fromJson(Map<String, dynamic> json) {
    return SwapKitRouteEstimateTime(
        inbound: json.as("inbound"),
        swap: json.as("swap"),
        outbound: json.as("outbound"),
        total: json.as("total"));
  }
  Map<String, dynamic> toJson() {
    return {
      "inbound": inbound,
      "swap": swap,
      "outbound": outbound,
      "total": total
    };
  }
}

class SwapKitRouteWarning {
  final String code;
  final String display;
  final String tooltip;
  const SwapKitRouteWarning(
      {required this.code, required this.display, required this.tooltip});
  factory SwapKitRouteWarning.fromJson(Map<String, dynamic> json) {
    return SwapKitRouteWarning(
        code: json.as("code"),
        display: json.as("display"),
        tooltip: json.as("tooltip"));
  }
  Map<String, dynamic> toJson() {
    return {"code": code, "display": display, "tooltip": tooltip};
  }
}

class SwapKitTrack {
  /// The chain ID where the transaction occurred.
  final String chainId;

  /// The transaction hash.
  final String hash;

  /// The block number where the transaction was included.
  final int block;

  /// The type of the transaction
  final String type;

  /// The transaction status
  final String status;

  /// The current tracking status.
  final String trackingStatus;

  /// The asset being sent.
  final String fromAsset;

  /// The amount of fromAsset
  final String fromAmount;

  /// The address sending the asset.
  final String fromAddress;

  /// The asset being received.
  final String toAsset;

  /// The amount of toAsset.
  final String toAmount;

  /// The recipient address.
  final String toAddress;

  /// UNIX timestamp indicating when the transaction finalized.
  final int finalisedAt;

  ///  Metadata including images and provider info.
  final SwapKitTrackMeta meta;

  /// Additional transaction specific data.
  final SwapKitTrackPayload payload;

  /// Detailed breakdown of each transaction leg.
  final List<SwapKitTrackLeg> legs;

  SwapKitTrack({
    required this.chainId,
    required this.hash,
    required this.block,
    required this.type,
    required this.status,
    required this.trackingStatus,
    required this.fromAsset,
    required this.fromAmount,
    required this.fromAddress,
    required this.toAsset,
    required this.toAmount,
    required this.toAddress,
    required this.finalisedAt,
    required this.meta,
    required this.payload,
    required this.legs,
  });

  factory SwapKitTrack.fromJson(Map<String, dynamic> json) {
    return SwapKitTrack(
      chainId: json['chainId'],
      hash: json['hash'],
      block: json['block'],
      type: json['type'],
      status: json['status'],
      trackingStatus: json['trackingStatus'],
      fromAsset: json['fromAsset'],
      fromAmount: json['fromAmount'],
      fromAddress: json['fromAddress'],
      toAsset: json['toAsset'],
      toAmount: json['toAmount'],
      toAddress: json['toAddress'],
      finalisedAt: json['finalisedAt'],
      meta: SwapKitTrackMeta.fromJson(json['meta']),
      payload: SwapKitTrackPayload.fromJson(json['payload']),
      legs: (json['legs'] as List)
          .map((legJson) => SwapKitTrackLeg.fromJson(legJson))
          .toList(),
    );
  }
}

class SwapKitTrackMeta {
  final String provider;
  final String providerAction;
  final SwapKitTrackImages images;

  SwapKitTrackMeta({
    required this.provider,
    required this.providerAction,
    required this.images,
  });

  factory SwapKitTrackMeta.fromJson(Map<String, dynamic> json) {
    return SwapKitTrackMeta(
      provider: json['provider'],
      providerAction: json['providerAction'],
      images: SwapKitTrackImages.fromJson(json['images']),
    );
  }
}

class SwapKitTrackImages {
  final String from;
  final String to;
  final String provider;
  final String chain;

  SwapKitTrackImages({
    required this.from,
    required this.to,
    required this.provider,
    required this.chain,
  });

  factory SwapKitTrackImages.fromJson(Map<String, dynamic> json) {
    return SwapKitTrackImages(
      from: json['from'],
      to: json['to'],
      provider: json['provider'],
      chain: json['chain'],
    );
  }
}

class SwapKitTrackPayload {
  final String memo;
  final String? thorname;

  SwapKitTrackPayload({required this.memo, this.thorname});

  factory SwapKitTrackPayload.fromJson(Map<String, dynamic> json) {
    return SwapKitTrackPayload(
      memo: json['memo'],
      thorname: json['thorname'],
    );
  }
}

class SwapKitChainFlipDepositChannel {
  final String depositAddress;
  final String channelId;
  final String explorerUrl;
  const SwapKitChainFlipDepositChannel(
      {required this.depositAddress,
      required this.channelId,
      required this.explorerUrl});
  factory SwapKitChainFlipDepositChannel.fromJson(Map<String, dynamic> json) {
    return SwapKitChainFlipDepositChannel(
        depositAddress: json.as("depositAddress"),
        channelId: json.as("channelId"),
        explorerUrl: json.as("explorerUrl"));
  }
  Map<String, dynamic> toJson() {
    return {
      "depositAddress": depositAddress,
      "channelId": channelId,
      "explorerUrl": explorerUrl
    };
  }
}

class SwapKitTrackLeg {
  final String chainId;
  final String hash;
  final int block;
  final String type;
  final String status;
  final String trackingStatus;
  final String fromAsset;
  final String fromAmount;
  final String fromAddress;
  final String toAsset;
  final String toAmount;
  final String toAddress;
  final int finalisedAt;
  final SwapKitTrackMeta meta;
  final SwapKitTrackPayload payload;

  SwapKitTrackLeg({
    required this.chainId,
    required this.hash,
    required this.block,
    required this.type,
    required this.status,
    required this.trackingStatus,
    required this.fromAsset,
    required this.fromAmount,
    required this.fromAddress,
    required this.toAsset,
    required this.toAmount,
    required this.toAddress,
    required this.finalisedAt,
    required this.meta,
    required this.payload,
  });

  factory SwapKitTrackLeg.fromJson(Map<String, dynamic> json) {
    return SwapKitTrackLeg(
      chainId: json['chainId'],
      hash: json['hash'],
      block: json['block'],
      type: json['type'],
      status: json['status'],
      trackingStatus: json['trackingStatus'],
      fromAsset: json['fromAsset'],
      fromAmount: json['fromAmount'],
      fromAddress: json['fromAddress'],
      toAsset: json['toAsset'],
      toAmount: json['toAmount'],
      toAddress: json['toAddress'],
      finalisedAt: json['finalisedAt'],
      meta: SwapKitTrackMeta.fromJson(json['meta']),
      payload: SwapKitTrackPayload.fromJson(json['payload']),
    );
  }
}

class SwipKitScreenParams {
  final String address;
  final String chain;
  const SwipKitScreenParams({required this.address, required this.chain});
}
