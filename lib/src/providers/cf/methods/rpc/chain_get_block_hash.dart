import 'package:on_chain_swap/src/providers/cf/core/core.dart';

class CfRPCRequestChainGetBlockHash extends CfRPCRequestParam<String, String> {
  final int? blockHeight;
  const CfRPCRequestChainGetBlockHash({this.blockHeight});
  @override
  String get method => "chain_getBlockHash";
  @override
  List get params => [blockHeight];
}
