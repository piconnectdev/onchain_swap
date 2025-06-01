import 'package:on_chain_swap/src/providers/cf/core/core.dart';

class CfRPCRequestAccounts extends CfRPCRequestParam<List<List<String>>, List> {
  @override
  String get method => "cf_accounts";
  @override
  List<List<String>> onResonse(List result) {
    return result.map((e) => List<String>.from(e)).toList();
  }
}
