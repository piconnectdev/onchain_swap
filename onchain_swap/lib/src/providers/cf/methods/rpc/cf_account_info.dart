import 'package:onchain_swap/src/providers/cf/core/core.dart';

class CfRPCRequestAccountsInfo extends CfRPCRequestParam {
  final String accountId;
  const CfRPCRequestAccountsInfo(this.accountId);
  @override
  List get params => [accountId];
  @override
  String get method => "cf_account_info";
}
