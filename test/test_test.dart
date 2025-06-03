void main() {}
const b = {
  "json": {
    "srcAsset": "ETH",
    "srcChain": "Ethereum",
    "destAsset": "BTC",
    "destChain": "Bitcoin",
    "srcAddress": null,
    "destAddress":
        "tb1pgdw72nzzgzkzhzc3kps9nzsydts2sxyy3vay3uhw33tnv6mvnzgsdujvdt",
    "dcaParams": null,
    "fillOrKillParams": {
      "refundAddress": "0x64a01564edB3e4a914DE27EE7758198bfFedDEdE",
      "retryDurationBlocks": 50,
      "minPriceX128": "50150058108541511657150943635"
    },
    "maxBoostFeeBps": null,
    "ccmParams": null,
    "amount": "100000000000000000",
    "quote": {
      "intermediateAmount": "2424740879",
      "egressAmount": "14808665",
      "recommendedSlippageTolerancePercent": 0.5,
      "includedFees": [
        {
          "chain": "Ethereum",
          "asset": "ETH",
          "amount": "5000429250000",
          "type": "INGRESS"
        },
        {
          "chain": "Ethereum",
          "asset": "USDC",
          "amount": "2430814",
          "type": "NETWORK"
        },
        {
          "chain": "Ethereum",
          "asset": "USDC",
          "amount": "3642575",
          "type": "BROKER"
        },
        {"chain": "Bitcoin", "asset": "BTC", "amount": "2431", "type": "EGRESS"}
      ],
      "lowLiquidityWarning": false,
      "poolInfo": [
        {
          "baseAsset": {"chain": "Ethereum", "asset": "ETH"},
          "quoteAsset": {"chain": "Ethereum", "asset": "USDC"},
          "fee": {"chain": "Ethereum", "asset": "ETH", "amount": "0"}
        },
        {
          "baseAsset": {"chain": "Bitcoin", "asset": "BTC"},
          "quoteAsset": {"chain": "Ethereum", "asset": "USDC"},
          "fee": {"chain": "Ethereum", "asset": "USDC", "amount": "0"}
        }
      ],
      "estimatedDurationsSeconds": {"swap": 12, "deposit": 90, "egress": 690},
      "estimatedDurationSeconds": 792,
      "estimatedPrice": "1.48118366554125794723",
      "type": "REGULAR",
      "srcAsset": {"chain": "Ethereum", "asset": "ETH"},
      "destAsset": {"chain": "Bitcoin", "asset": "BTC"},
      "depositAmount": "100000000000000000",
      "isVaultSwap": false
    },
    "takeCommission": true
  },
  "meta": {
    "values": {
      "srcAddress": ["undefined"],
      "dcaParams": ["undefined"],
      "maxBoostFeeBps": ["undefined"],
      "ccmParams": ["undefined"]
    }
  }
};
const r = {
  "json": {
    "srcAsset": "ETH",
    "srcChain": "Ethereum",
    "destAsset": "BTC",
    "destChain": "Bitcoin",
    "srcAddress": null,
    "destAddress": "mju61fosB2S8zYbxAuoMeufjVMnhZ2NvFv",
    "dcaParams": null,
    "fillOrKillParams": {
      "refundAddress": "0x64a01564edB3e4a914DE27EE7758198bfFedDEdE",
      "minPriceX128": "50747224738486570380759771684",
      "retryDurationBlocks": 50
    },
    "maxBoostFeeBps": null,
    "ccmParams": null,
    "amount": "10000000000000000",
    "quote": {
      "srcAsset": {"asset": "ETH", "chain": "Ethereum"},
      "destAsset": {"asset": "BTC", "chain": "Bitcoin"},
      "isVaultSwap": false,
      "depositAmount": "10000000000000000",
      "intermediateAmount": "243674566",
      "recommendedSlippageTolerancePercent": 0.5,
      "egressAmount": "1496652",
      "includedFees": [
        {
          "type": "INGRESS",
          "chain": "Ethereum",
          "asset": "ETH",
          "amount": "60098150000"
        },
        {
          "type": "NETWORK",
          "chain": "Ethereum",
          "asset": "USDC",
          "amount": "243918"
        },
        {"type": "EGRESS", "chain": "Bitcoin", "asset": "BTC", "amount": "2160"}
      ],
      "poolInfo": [
        {
          "baseAsset": {"asset": "ETH", "chain": "Ethereum"},
          "quoteAsset": {"asset": "USDC", "chain": "Ethereum"},
          "fee": {
            "type": "LIQUIDITY",
            "chain": "Ethereum",
            "asset": "ETH",
            "amount": "0"
          }
        },
        {
          "baseAsset": {"asset": "BTC", "chain": "Bitcoin"},
          "quoteAsset": {"asset": "USDC", "chain": "Ethereum"},
          "fee": {
            "type": "LIQUIDITY",
            "chain": "Ethereum",
            "asset": "USDC",
            "amount": "0"
          }
        }
      ],
      "lowLiquidityWarning": false,
      "estimatedDurationSeconds": 792,
      "estimatedDurationsSeconds": {"deposit": 90, "swap": 12, "egress": 690},
      "estimatedPrice": "1.4988210076369740118",
      "type": "REGULAR"
    }
  },
  "meta": {
    "values": {
      "srcAddress": ["undefined"],
      "dcaParams": ["undefined"],
      "maxBoostFeeBps": ["undefined"],
      "ccmParams": ["undefined"]
    }
  }
};
