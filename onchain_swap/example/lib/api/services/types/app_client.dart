import 'package:example/app/types/types.dart';
import 'package:onchain_swap/onchain_swap.dart';

class AppClient {
  final NetworkClient client;
  final DynamicVoid? _dispose;
  AppClient({required this.client, DynamicVoid? dispose}) : _dispose = dispose;
  void close() {
    _dispose?.call();
  }
}
