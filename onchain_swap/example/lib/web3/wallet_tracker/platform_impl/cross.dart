import 'package:onchain_swap/onchain_swap.dart' show SwapNetwork;
import 'package:example/web3/wallet_tracker/core/core.dart';

WalletTracker walletTracker({required SwapNetwork network}) =>
    throw UnsupportedError(
        'Cannot create a instance without dart:js_interop or dart:io.');
